//
//  CustomButton.m
//  FriendMap
//
//  Created by Gildardo Banuelos on 7/13/21.
//

#import "CustomButton.h"

@implementation UIImage (Utils)

+ (UIImage *)imageWithSize:(CGSize)size color:(UIColor *)color
{
    UIGraphicsBeginImageContextWithOptions(size, true, 0.0);
    [color setFill];
    UIRectFill(CGRectMake(0.0, 0.0, size.width, size.height));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end

@implementation CustomButton: UIButton

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {

        UIImage *bgImage = [UIImage imageWithSize:self.bounds.size color:UIColor.blackColor];
        [self setBackgroundImage:bgImage forState:UIControlStateNormal];
        [self setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        self.layer.cornerRadius = 10.0;
        self.layer.masksToBounds = YES;
        
        self.titleLabel.font = [UIFont systemFontOfSize:18.0 weight:UIFontWeightRegular];
    }
    return self;
}

@end
