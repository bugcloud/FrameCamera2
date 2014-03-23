//
//  UIImage+H568.m
//  FrameCamera
//
//  Created by Nagino Yuki on 2012/12/06.
//  Copyright (c) 2012年 RaD Inc. All rights reserved.
//

#import "UIImage+H568.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation UIImage (H568)

+ (void)load {
    if  ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) &&
         ([UIScreen mainScreen].bounds.size.height > 480.0f)) {

        method_exchangeImplementations(
                                       class_getClassMethod(self, @selector(imageNamed:)),
                                       class_getClassMethod(self, @selector(imageNamedH568:)));
        
        method_exchangeImplementations(
                                       class_getClassMethod(self, @selector(imageWithContentsOfFile:)),
                                       class_getClassMethod(self, @selector(imageWithContentsOfFileH568:)));
    }
}

+ (UIImage *)imageNamedH568:(NSString *)imageName {
    return [UIImage imageNamedH568:[self imageNameH568:imageName isBundleResource:YES]];
}

+ (UIImage *)imageWithContentsOfFileH568:(NSString *)path {
    return [UIImage imageWithContentsOfFileH568:[self imageNameH568:path isBundleResource:NO]];
}

+ (NSString *)imageNameH568:(NSString *)imageName isBundleResource:(BOOL)isBundle {
    NSMutableString *imageNameMutable = [imageName mutableCopy];
    
    //Delete png extension
    NSRange extension = [imageName rangeOfString:@".png" options:NSBackwardsSearch | NSAnchoredSearch];
    if (extension.location != NSNotFound) {
        [imageNameMutable deleteCharactersInRange:extension];
    }
    
    //Look for @2x to introduce -568h string
    NSRange retinaAtSymbol = [imageName rangeOfString:@"@2x"];
    if (retinaAtSymbol.location != NSNotFound) {
        [imageNameMutable insertString:@"-568h" atIndex:retinaAtSymbol.location];
    } else {
        [imageNameMutable appendString:@"-568h@2x"];
    }
    
    NSString *returnName = imageName;
    if (isBundle) {
        //Check if the image exists and load the new 568 if so or the original name if not
        NSString *imagePath = [[NSBundle mainBundle] pathForResource:imageNameMutable ofType:@"png"];
        if (imagePath) {
            //Remove the @2x to load with the correct scale 2.0
            [imageNameMutable replaceOccurrencesOfString:@"@2x" withString:@"" options:NSBackwardsSearch range:NSMakeRange(0, [imageNameMutable length])];
            returnName = imageNameMutable;
        }
    } else {
        [imageNameMutable appendString:@".png"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:imageNameMutable]) {
            returnName = imageNameMutable;
        }
    }
    return returnName;
}

@end
