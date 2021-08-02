//
//  LoginViewController.m
//  FriendMap
//
//  Created by Gildardo Banuelos on 7/13/21.
//

#import "LoginViewController.h"
#import <Parse/Parse.h>

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)showPopup{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Invalid information!"
    message:@"Enter valid information in text fields!"
    preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)loginUser{
    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;
    
    typeof(self) __weak weakSelf = self;
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error){
        typeof(weakSelf) strongSelf = weakSelf;
        if(error!=nil){
            [strongSelf showPopup];
        } else {
            NSLog(@"User logged in successfully");
            [strongSelf performSegueWithIdentifier:@"loginSegue" sender:strongSelf.loginButton];
        }
    }];
}

- (IBAction)onClickLogin:(id)sender{
    if([self.usernameField.text isEqual:@""] || [self.passwordField.text isEqual:@""]){
        [self showPopup];
    }
    [self loginUser];
}

- (IBAction)onClickBackground:(id)sender{
    [self.view endEditing:true];
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
