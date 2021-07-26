//
//  ProfileViewController.m
//  FriendMap
//
//  Created by Gildardo Banuelos on 7/13/21.
//

#import "ProfileViewController.h"
#import <Parse/Parse.h>
#import "LoginViewController.h"

@interface ProfileViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@end

@implementation ProfileViewController

- (IBAction)onClickCamera:(id)sender{
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;

    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else {
        NSLog(@"Camera 🚫 available so we will use photo library instead");
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }

    [self presentViewController:imagePickerVC animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    // Get the image captured by the UIImagePickerController
    UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];
    self.profileImage.image = editedImage;
    NSData *imageData = UIImagePNGRepresentation(editedImage);
    PFFileObject *imageFile = [PFFileObject fileObjectWithName:@"image.png" data:imageData];
    PFQuery *query = [PFQuery queryWithClassName:@"_User"];
    [query getObjectInBackgroundWithId:self.user.objectId block:^(PFObject *group, NSError *error) {
            if (!error){
                [group setObject:imageFile forKey:@"profile_picture"];
                [group saveInBackground];
            }
        [self dismissViewControllerAnimated:YES completion:nil];
        }];
    
}

- (IBAction)onClickLogout:(id)sender{
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error){
        NSLog(@"User Logged out successfully!");
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        [[UIApplication sharedApplication].keyWindow setRootViewController: loginViewController];
    }];
}
 
- (void)viewDidLoad{
    [super viewDidLoad];
    

}

- (void)viewDidAppear:(BOOL)animated{
    NSLog(@"%@", self.user);
    if(self.user==nil || [PFUser.currentUser.username isEqual:self.user[@"username"]]){ // when user goes to their own profile screen via tab menu
        NSLog(@"own profile");
        [self.cameraButton setHidden:NO];
        PFQuery *query = [PFQuery queryWithClassName:@"_User"];
        [query getObjectInBackgroundWithId:PFUser.currentUser.objectId block:^(PFObject *user, NSError *error) {
                if (!error){
                    self.user = user;
                    self.title = self.user[@"username"];
                    NSArray *all_groups = self.user[@"all_groups"];
                    self.numberOfGroupsLabel.text = [NSString stringWithFormat:@"This user is part of %lu groups.", (unsigned long)all_groups.count];
                    if(user[@"profile_picture"]){
                        [user[@"profile_picture"] getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error){
                            if(!error){
                                self.profileImage.image = [UIImage imageWithData:imageData];
                            }
                        }];
                    }else{
                        self.profileImage.image = [UIImage systemImageNamed:@"questionmark.square"];
                    }
                }
            }];
        
    }else{ // view for another profile - not own profile
        [self.cameraButton setHidden:self.hideCameraButton];
        NSArray *all_groups = self.user[@"all_groups"];
        self.numberOfGroupsLabel.text = [NSString stringWithFormat:@"This user is part of %lu groups.", (unsigned long)all_groups.count];
        if(self.UsersAndImages[self.user.username]){
            self.profileImage.image = [UIImage imageWithData:self.UsersAndImages[self.user.username]];
        }else{
            self.profileImage.image = [UIImage systemImageNamed:@"questionmark.square"];
        }
        
    }

    
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
