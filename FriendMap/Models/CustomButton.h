//
//  CustomButton.h
//  FriendMap
//
//  Created by Gildardo Banuelos on 7/13/21.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Utils)
+ (UIImage *)imageWithSize:(CGSize)size color:(UIColor *)color;
@end

@interface CustomButton : UIButton
- (instancetype)initWithCoder:(NSCoder *)coder;
@end

NS_ASSUME_NONNULL_END
