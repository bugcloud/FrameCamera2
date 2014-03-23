//
//  FRCHorizontalImageView.m
//  FrameCamera2
//

#import "FRCHorizontalImageView.h"

@implementation FRCHorizontalImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGPoint p = CGPointZero;
    for (UIImage *img in _imageList) {
        [img drawAtPoint:p];
        p.x += img.size.width;
    }
}

@end
