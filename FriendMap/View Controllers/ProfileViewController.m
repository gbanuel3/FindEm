//
//  ProfileViewController.m
//  FriendMap
//
//  Created by Gildardo Banuelos on 7/13/21.
//

#import "ProfileViewController.h"
#import <Parse/Parse.h>
#import "LoginViewController.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

- (IBAction)onClickLogout:(id)sender{
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error){
        NSLog(@"User Logged out successfully!");
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        [[UIApplication sharedApplication].keyWindow setRootViewController: loginViewController];
    }];
}
 
- (void)viewDidLoad {
    [super viewDidLoad];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
