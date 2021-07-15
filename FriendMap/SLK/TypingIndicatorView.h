//
//  TypingIndicatorView.h
//  FriendMap
//
//  Created by Gildardo Banuelos on 7/15/21.
//

#import <UIKit/UIKit.h>
#import "SLKTypingIndicatorProtocol.h"

static CGFloat kTypingIndicatorViewMinimumHeight = 80.0;
static CGFloat kTypingIndicatorViewAvatarHeight = 30.0;

@interface TypingIndicatorView : UIView <SLKTypingIndicatorProtocol>

- (void)presentIndicatorWithName:(NSString *)name image:(UIImage *)image;
- (void)dismissIndicator;

@end
