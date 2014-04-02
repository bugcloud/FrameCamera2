//
//  FRCSettingViewController.m
//  FrameCamera2
//

#import "FRCSettingViewController.h"
#import "FRCSettingHelper.h"
#import "MBProgressHUD.h"

@interface FRCSettingViewController ()

@end

@implementation FRCSettingViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _valueForDateVisible = [FRCSettingHelper showDate];
        _valueForQREnable = [FRCSettingHelper showQR];
        _valueForUserName = [FRCSettingHelper userName];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_switchForDateVisible setOn:_valueForDateVisible];
    [_switchForQREnable setOn:_valueForQREnable];
    [_textFieldForName setText:_valueForUserName];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

/*
   #pragma mark - Navigation

   // In a storyboard-based application, you will often want to do a little preparation before navigation
   - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
   {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
   }
 */

- (IBAction)saveSettings:(id)sender
{
    _valueForUserName = _textFieldForName.text;
    // Hide keyboard
    [self textFieldShouldReturn:_textFieldForName];
    // Show loading view and fetch images
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Do asynchronous process
        NSDictionary *settings = @{
            kFRCKeyForUserNameSetting: _valueForUserName,
            kFRCKeyForDateVisibleSetting: [NSNumber numberWithBool:_valueForDateVisible],
            kFRCKeyForQREnableSetting: [NSNumber numberWithBool:_valueForQREnable]
        };
        [FRCSettingHelper saveSetting:settings];

        if (_valueForUserName != nil && [_valueForUserName length] > 0) {
            // Remove all file
            NSError *error;
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSString *docPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
            NSArray *pathes = [fileManager contentsOfDirectoryAtPath:docPath
                                                               error:&error];
            if (error) {
                [self showErrorDialog];
            }
            for (NSString *p in pathes) {
                NSString *rmFile = [docPath stringByAppendingPathComponent:p];
                [fileManager removeItemAtPath:rmFile error:nil];
            }

            // Fetch resources' json
            NSURL *jsonUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://rad.bugcloud.com/api/users/%@/resources", _valueForUserName]];
            NSData *jsonData = [NSData dataWithContentsOfURL:jsonUrl];
            // Show alert unless app could get json data
            if (jsonData == nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showErrorDialog];
                });
            } else {
                error = nil;
                NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
                if (error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self showErrorDialog];
                    });
                }
                //LOG(@"%@", jsonDict);
                NSMutableArray *resourceUrls = [NSMutableArray arrayWithCapacity:0];
                for (NSDictionary *dict in jsonDict[@"frames"]) {
                    [resourceUrls addObject:dict[@"img_normal"]];
                    [resourceUrls addObject:dict[@"img_2x"]];
                    [resourceUrls addObject:dict[@"img_568h"]];
                }
                // Fetch images according to JSON
                int count = 0;
                int frameNumber = 0;
                for (NSString *url in resourceUrls) {
                    NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
                    NSString *newFileName;
                    int ext = count % 3;
                    if (ext == 0) frameNumber++;
                    if (ext == 1) {
                        newFileName = [NSString stringWithFormat:@"frame%d@2x.png", frameNumber];
                    } else if (ext == 2) {
                        newFileName = [NSString stringWithFormat:@"frame%d-568h@2x.png", frameNumber];
                    } else {
                        newFileName = [NSString stringWithFormat:@"frame%d.png", frameNumber];
                    }
                    NSString *newFilePath = [docPath stringByAppendingPathComponent:newFileName];
                    if (![imgData writeToFile:newFilePath atomically:YES]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self showErrorDialog];
                        });
                    }
                    count++;
                }
            }
        } else {
            // usernameを入力していない場合は設定をクリアする
            [FRCSettingHelper clear];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (self.delegate) {
                [self.delegate FRCSettingViewController:self didFinishSavingSettings:settings];
            }
        });
    });
}

- (IBAction)switchForDateVisibleHasChanged:(id)sender
{
    _valueForDateVisible = [sender isOn];
}

- (IBAction)switchForQREnableHasChanged:(id)sender
{
    _valueForQREnable = [sender isOn];
}

- (void)showErrorDialog
{
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"failed_to_fetch_images", nil)
                                message:NSLocalizedString(@"please_check_your_username", nil)
                               delegate:self
                      cancelButtonTitle:NSLocalizedString(@"cancel", nil)
                      otherButtonTitles:NSLocalizedString(@"ok", nil), nil
     ] show];
}

#pragma mark -
#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)theTextField
{
    [_textFieldForName resignFirstResponder];
    return YES;
}

@end
