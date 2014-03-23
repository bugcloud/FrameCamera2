//
//  FRCSettingHelper.h
//  FrameCamera2
//

#import <Foundation/Foundation.h>

@interface FRCSettingHelper : NSObject

+ (void)saveSetting:(NSDictionary *)params;
+ (NSString *)userName;
+ (BOOL)showDate;
+ (void)clear;

@end
