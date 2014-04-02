//
//  FRCSettingViewController.h
//  FrameCamera2
//

#import <UIKit/UIKit.h>

@class FRCSettingViewController;

@protocol FRCSettingViewControllerDelegate
- (void)FRCSettingViewController:(FRCSettingViewController *)controller didFinishSavingSettings:(NSDictionary *)setting;
@end

@interface FRCSettingViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, assign) id <FRCSettingViewControllerDelegate> delegate;
@property (nonatomic, assign) BOOL valueForDateVisible;
@property (nonatomic, assign) BOOL valueForQREnable;
@property NSString *valueForUserName;
@property (weak) IBOutlet UISwitch *switchForDateVisible;
@property (weak) IBOutlet UISwitch *switchForQREnable;
@property (weak) IBOutlet UITextField *textFieldForName;

- (IBAction)saveSettings:(id)sender;
- (IBAction)switchForDateVisibleHasChanged:(id)sender;
- (IBAction)switchForQREnableHasChanged:(id)sender;

@end
