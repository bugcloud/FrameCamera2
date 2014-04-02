//
//  FRCSettingHelper.m
//  FrameCamera2
//

#import "FRCSettingHelper.h"

@implementation FRCSettingHelper

+ (void)saveSetting:(NSDictionary *)params
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    for (NSString *key in [params allKeys]) {
        if ([key compare:kFRCKeyForUserNameSetting] == NSOrderedSame) {
            [defaults setObject:params[kFRCKeyForUserNameSetting] forKey:kFRCKeyForUserNameSetting];
        } else if ([key compare:kFRCKeyForDateVisibleSetting] == NSOrderedSame) {
            [defaults setBool:[(NSNumber *)params[kFRCKeyForDateVisibleSetting] boolValue]
                       forKey:kFRCKeyForDateVisibleSetting];
        } else if ([key compare:kFRCKeyForQREnableSetting] == NSOrderedSame) {
            [defaults setBool:[(NSNumber *)params[kFRCKeyForQREnableSetting] boolValue]
                       forKey:kFRCKeyForQREnableSetting];
        }
    }
    [defaults synchronize];
}

+ (NSString *)userName
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:kFRCKeyForUserNameSetting];
}

+ (BOOL)showDate
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kFRCKeyForDateVisibleSetting];
}

+ (BOOL)showQR
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kFRCKeyForQREnableSetting];
}

+ (void)clear
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:kFRCKeyForDateVisibleSetting];
    [defaults removeObjectForKey:kFRCKeyForQREnableSetting];
    [defaults removeObjectForKey:kFRCKeyForUserNameSetting];
    [defaults synchronize];
}

@end
