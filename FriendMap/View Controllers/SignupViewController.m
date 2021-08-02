//
//  SignupViewController.m
//  FriendMap
//
//  Created by Gildardo Banuelos on 7/13/21.
//

#import "SignupViewController.h"
#import <Parse/Parse.h>

@interface SignupViewController ()

@end

@implementation SignupViewController
 
- (void)showPopup{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Invalid information!"
    message:@"Enter valid information in text fields!"
    preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)registerUser {
    PFUser *newUser = [PFUser user];
    newUser.username = self.usernameField.text;
    newUser.password = self.passwordField.text;
    typeof(self) __weak weakSelf = self;
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * error){
        typeof(weakSelf) strongSelf = weakSelf;
        if(error!=nil){
            [strongSelf showPopup];
        }else{
            [strongSelf performSegueWithIdentifier:@"loginSegue" sender:strongSelf.signupButton];
        }
    }];

}

- (IBAction)onClickSignup:(id)sender{
    if([self.usernameField.text isEqual:@""] || [self.passwordField.text isEqual:@""]){
        [self showPopup];
    }
    [self registerUser];
}

- (IBAction)onTapBackground:(id)sender{
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
