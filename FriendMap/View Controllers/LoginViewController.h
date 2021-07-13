//
//  LoginViewController.h
//  FriendMap
//
//  Created by Gildardo Banuelos on 7/13/21.
//

#import <UIKit/UIKit.h>
#import "CustomButton.h"

NS_ASSUME_NONNULL_BEGIN

@interface LoginViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet CustomButton *loginButton;
@property (weak, nonatomic) IBOutlet CustomButton *signupButton;


@end

NS_ASSUME_NONNULL_END
