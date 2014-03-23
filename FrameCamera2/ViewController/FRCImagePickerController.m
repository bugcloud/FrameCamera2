//
//  FRCImagePickerController.m
//  FrameCamera2
//

#import "FRCImagePickerController.h"
#import "FRCHorizontalImageView.h"
#import "FRCSettingHelper.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface FRCImagePickerController ()

@property NSArray *frameImages;
@property UILabel *dateLabel;
@property UIView *overlayView;
@property UIScrollView *frameScrollView;
@property (nonatomic, assign) NSInteger frameIndex;


@end

@implementation FRCImagePickerController

- (id)init
{
    self = [super init];
    if (self) {
        self.allowsEditing = NO;
        self.sourceType = UIImagePickerControllerSourceTypeCamera;
        self.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;
        self.showsCameraControls = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // set overlay view
    // TODO
    // This frame size is corrent on only iPhone5+ && iOS7
    _overlayView = [[UIView alloc] initWithFrame:CGRectMake(
                        0,
                        69,
                        self.view.bounds.size.width,
                        self.view.bounds.size.height - 69 - 73
                        )];
    [_overlayView setBackgroundColor:[UIColor clearColor]];
    _frameScrollView = [[UIScrollView alloc] initWithFrame:_overlayView.bounds];
    [_frameScrollView setPagingEnabled:YES];
    [_frameScrollView setShowsHorizontalScrollIndicator:NO];
    [_frameScrollView setShowsVerticalScrollIndicator:NO];
    [_frameScrollView setScrollsToTop:NO];
    _frameScrollView.delegate = self;

    NSDateFormatter *dtf = [[NSDateFormatter alloc] init];
    [dtf setDateFormat:@"yyyy/MM/dd"];
    _dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(222, 10, 150, 20)];
    [_dateLabel setHidden:YES];
    [_dateLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [_dateLabel setTextColor:[UIColor whiteColor]];
    [_dateLabel setBackgroundColor:[UIColor clearColor]];
    [_dateLabel setText:[dtf stringFromDate:[NSDate date]]];
    if ([FRCSettingHelper showDate]) {
        [_dateLabel setHidden:NO];
    }

    [_overlayView addSubview:_frameScrollView];
    [_overlayView addSubview:_dateLabel];
    [self updateFrameImages];
    [self setCameraOverlayView:_overlayView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateFrameImages
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *contents;
    NSString *userName = [FRCSettingHelper userName];
    BOOL useDefaultBundle = userName == nil || [userName length] <= 0;
    NSString *homeDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    if (useDefaultBundle) {
        contents = [[NSBundle mainBundle] pathsForResourcesOfType:@"png" inDirectory:nil];
    } else {
        contents = [fileManager contentsOfDirectoryAtPath:homeDir
                                                    error:nil];
    }

    NSMutableArray *imgs = [@[] mutableCopy];
    for (NSString *filePath in contents) {
        NSString *imageFilePath;
        if (useDefaultBundle) {
            imageFilePath = [[filePath componentsSeparatedByString:@"/"] lastObject];
        } else {
            imageFilePath = filePath;
        }
        if ([imageFilePath hasPrefix:@"frame"] && [imageFilePath rangeOfString:@"@"].length == 0) {
            if (useDefaultBundle) {
                [imgs addObject:[UIImage imageNamed:imageFilePath]];
            } else {
                imageFilePath = [homeDir stringByAppendingPathComponent:imageFilePath];
                [imgs addObject:[UIImage imageWithContentsOfFile:imageFilePath]];
            }
        }
    }
    _frameImages = [NSArray arrayWithArray:imgs];
    _frameIndex = 0;
    [_frameScrollView setContentSize:CGSizeMake(
         _frameScrollView.frame.size.width * [_frameImages count],
         _frameScrollView.frame.size.height
         )];

    FRCHorizontalImageView *iv = [[FRCHorizontalImageView alloc] initWithFrame:CGRectMake(
                                      0,
                                      0,
                                      self.view.bounds.size.width * [_frameImages count],
                                      self.view.bounds.size.height
                                      )];
    iv.imageList = _frameImages;
    iv.backgroundColor = [UIColor clearColor];
    for (UIView *view in _frameScrollView.subviews) {
        [view removeFromSuperview];
    }
    [_frameScrollView addSubview:iv];
    [self.delegate FRCImagePickerController:self didFrameImageChanged:_frameImages[_frameIndex]];
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

#pragma mark -
#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    CGFloat pageWidth = _frameScrollView.frame.size.width;
    _frameIndex = floor((_frameScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    [self.delegate FRCImagePickerController:self didFrameImageChanged:_frameImages[_frameIndex]];
}

@end
