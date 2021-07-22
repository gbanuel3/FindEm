//
//  SceneDelegate.h
//  FriendMap
//
//  Created by Gildardo Banuelos on 7/12/21.
//

#import <UIKit/UIKit.h>
#import "LocationManager.h"

@interface SceneDelegate : UIResponder <UIWindowSceneDelegate>

@property (strong, nonatomic) UIWindow * window;
@property (strong, nonatomic) LocationManager *shareModel;

@end

