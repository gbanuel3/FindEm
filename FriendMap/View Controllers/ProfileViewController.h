//
//  ProfileViewController.h
//  FriendMap
//
//  Created by Gildardo Banuelos on 7/13/21.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "Message.h"

NS_ASSUME_NONNULL_BEGIN

@interface ProfileViewController : UIViewController

@property (strong, nonatomic) PFUser *user;
@property (strong, nonatomic) Message *message;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property bool hideCameraButton;
@property (weak, nonatomic) IBOutlet UILabel *numberOfGroupsLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceFromUserLabel;
@property (strong, nonatomic) NSDictionary *UsersAndImages;
@property (strong, nonatomic) NSMutableDictionary *UserAndUserObjects;

@end

NS_ASSUME_NONNULL_END
