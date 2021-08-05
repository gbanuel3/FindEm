//
//  RootViewController.h
//  FriendMap
//
//  Created by Gildardo Banuelos on 8/5/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RootViewController : UITabBarController

@property UIInterfaceOrientationMask nextOrientationMask;
- (void)resetNextOrientationMask;

@end

NS_ASSUME_NONNULL_END
