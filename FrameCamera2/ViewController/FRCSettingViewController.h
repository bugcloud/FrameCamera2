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
@property NSString *valueForUserName;
@property (weak) IBOutlet UISwitch *switchForDateVisible;
@property (weak) IBOutlet UITextField *textFieldForName;

- (IBAction)saveSettings:(id)sender;
- (IBAction)switchForDateVisibleHasChanged:(id)sender;

@end
