//
//  FRCViewController.m
//  FrameCamera2
//

#import "FRCViewController.h"
#import "FRCSettingHelper.h"
#import "MBProgressHUD.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface FRCViewController ()

@property UIImage *frameImage;

@end

@implementation FRCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)launchCamera:(id)sender
{
    FRCImagePickerController *picker = [[FRCImagePickerController alloc] init];
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:^{}];
}

- (IBAction)dismissSettingViewForSegue:(UIStoryboardSegue *)segue
{
    // dismiss FRCSettingViewController
}

#pragma mark -
#pragma UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:NO completion:^{
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
            if (_frameImage) {
                CGSize size = [image size];
                UIGraphicsBeginImageContext(size);
                CGRect rect;
                rect.origin = CGPointZero;
                rect.size = size;

                [image drawInRect:rect];
                [_frameImage drawInRect:rect blendMode:kCGBlendModeNormal alpha:1.0];

                //add current date
                //TODO I should set the position of date dynamically
                if ([FRCSettingHelper showDate]) {
                    NSDateFormatter *dtf = [[NSDateFormatter alloc] init];
                    [dtf setDateFormat:@"yyyy/MM/dd"];
                    int y = 72;
                    int fontSize = 96;
                    if (rect.size.width > 1936) {
                        y = 100;
                        fontSize = 110;
                    }
                    NSString *dateStr = [dtf stringFromDate:[NSDate date]];
                    CGRect dateRect = CGRectMake(rect.size.width * 0.69, y, rect.size.width, rect.size.height);
                    [dateStr drawInRect:dateRect
                         withAttributes:@{
                         NSFontAttributeName: [UIFont boldSystemFontOfSize:fontSize],
                         NSForegroundColorAttributeName: [UIColor whiteColor]
                     }];
                }

                UIImage *mergedImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                image = mergedImage;
            }
            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
            [library writeImageToSavedPhotosAlbum:image.CGImage
                                      orientation:(ALAssetOrientation)image.imageOrientation
                                  completionBlock:^(NSURL *assetURL, NSError *error) {
                if (error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"failed_to_save_images", nil)
                                                    message:NSLocalizedString(@"please_retake_a_picture", nil)
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"cancel", nil)
                                          otherButtonTitles:NSLocalizedString(@"ok", nil), nil
                         ] show];
                    });
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                });
            }];
        });
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

#pragma mark -
#pragma FRCImagePickerViewDelegate
- (void)FRCImagePickerController:(FRCImagePickerController *)controller didFrameImageChanged:(UIImage *)frameImage
{
    _frameImage = frameImage;
}

@end
