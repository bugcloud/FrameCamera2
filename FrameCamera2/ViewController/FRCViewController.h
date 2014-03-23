//
//  FRCViewController.h
//  FrameCamera2
//

#import <UIKit/UIKit.h>
#import "FRCImagePickerController.h"

@interface FRCViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, FRCImagePickerControllerDelegate>

@property (weak) IBOutlet UIButton *cameraBtn;
@property (weak) IBOutlet UIButton *settingBtn;

- (IBAction)launchCamera:(id)sender;
- (IBAction)dismissSettingViewForSegue:(UIStoryboardSegue *)segue;

@end
