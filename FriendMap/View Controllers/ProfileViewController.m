//
//  ProfileViewController.m
//  FriendMap
//
//  Created by Gildardo Banuelos on 7/13/21.
//

#import "ProfileViewController.h"
#import <Parse/Parse.h>
#import "LoginViewController.h"
#import "GroupViewController.h"
#import "RootViewController.h"

@interface ProfileViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate>

@end

@implementation ProfileViewController

- (void)getInfoFromGroupScreen{
    GroupViewController *groupViewController = (GroupViewController *) [[(UINavigationController*)[[self.tabBarController viewControllers] objectAtIndex:0] viewControllers] objectAtIndex:0];
    
    self.UsersAndImages = groupViewController.UsersAndImages;
    self.UserAndUserObjects = groupViewController.UserAndUserObjects;
}

- (void)startAnimator{
    CABasicAnimation *animation = [[CABasicAnimation alloc] init];
    animation.keyPath = @"transform.scale";
    animation.toValue = @1.5;
    animation.duration = 2;
    animation.repeatCount = INFINITY;
    animation.autoreverses = YES;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [self.cameraButton.layer addAnimation:animation forKey:nil];
}

- (IBAction)onClickBackground:(id)sender{
    [self.view endEditing:YES];
}

- (IBAction)onClickSave:(id)sender{
    if(![self.captionTextField.text isEqual:@""]){
        [self.user setObject:self.captionTextField.text forKey:@"profileDescription"];
        [self.user saveInBackground];
    }
}

- (void)textBoxOptions{
    self.captionTextField.autocorrectionType = NO;
    self.captionTextField.backgroundColor = [UIColor secondarySystemBackgroundColor];
    self.captionTextField.textColor = [UIColor blackColor];
    self.captionTextField.layer.cornerRadius = 20;
    self.captionTextField.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 10);
    self.captionTextField.layer.shadowColor = [UIColor grayColor].CGColor;
    self.captionTextField.layer.shadowOffset = CGSizeMake(.75, .75);
    self.captionTextField.layer.shadowOpacity = .4;
    self.captionTextField.layer.shadowRadius = 20;
    self.captionTextField.layer.masksToBounds = NO;
    
}

- (void)setCurrentTownLatitude:(NSNumber *)latitude longitude: (NSNumber *)longitude{
    CLGeocoder *ceo = [[CLGeocoder alloc]init];
    CLLocation *loc = [[CLLocation alloc]initWithLatitude:latitude.floatValue longitude:longitude.floatValue];
    typeof(self) __weak weakSelf = self;
    [ceo reverseGeocodeLocation: loc completionHandler:
     ^(NSArray *placemarks, NSError *error){
        typeof(weakSelf) strongSelf = weakSelf;
         CLPlacemark *placemark = [placemarks objectAtIndex:0];

        NSString *address = [NSString stringWithFormat:@"%@ %@, %@", [placemark.addressDictionary valueForKey:@"City"], [placemark.addressDictionary valueForKey:@"State"], [placemark.addressDictionary valueForKey:@"Country"]];
        strongSelf.currentLocationLabel.text = address;
     }];
}

- (IBAction)onClickGetDirections:(id)sender{
    PFUser *currentUser = self.UserAndUserObjects[[NSString stringWithFormat:@"%@", PFUser.currentUser.username]];
    NSNumber *currentUserLat = currentUser[@"lat"];
    NSNumber *currentUserLon = currentUser[@"lon"];
    NSNumber *profileUserLat = self.user[@"lat"];
    NSNumber *profileUserLon = self.user[@"lon"];
    
    NSString* directionsURL = [NSString stringWithFormat:@"http://maps.apple.com/?saddr=%f,%f&daddr=%f,%f",currentUserLat.floatValue, currentUserLon.floatValue, profileUserLat.floatValue, profileUserLon.floatValue];
    if([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:options:completionHandler:)]){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: directionsURL] options:@{} completionHandler:^(BOOL success){}];
    }else{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: directionsURL]];
    }
}

- (IBAction)onClickCamera:(id)sender{
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;

    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
    }else{
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }

    [self presentViewController:imagePickerVC animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];
    self.profileImage.image = editedImage;
    NSData *imageData = UIImagePNGRepresentation(editedImage);
    PFFileObject *imageFile = [PFFileObject fileObjectWithName:@"image.png" data:imageData];
    PFQuery *query = [PFQuery queryWithClassName:@"_User"];
    typeof(self) __weak weakSelf = self;
    [query getObjectInBackgroundWithId:self.user.objectId block:^(PFObject *group, NSError *error){
        typeof(weakSelf) strongSelf = weakSelf;
        if(!error){
            [group setObject:imageFile forKey:@"profile_picture"];
            [group saveInBackground];
        }
        [strongSelf dismissViewControllerAnimated:YES completion:nil];
    }];
    
}

- (IBAction)onClickLogout:(id)sender{
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error){
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        [[UIApplication sharedApplication].keyWindow setRootViewController: loginViewController];
    }];
}
 
- (void)viewDidLoad{
    [super viewDidLoad];
    self.captionTextField.delegate = self;
    [self textBoxOptions];
}

- (void)forcePortraitOrientation{
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger: UIInterfaceOrientationPortrait] forKey:@"orientation"];
}

- (void)viewDidDisappear:(BOOL)animated{
    [((RootViewController *)self.tabBarController) resetNextOrientationMask];
    [super viewDidDisappear:animated];
}


- (void)viewDidAppear:(BOOL)animated{
    [self forcePortraitOrientation];
    RootViewController *p = (RootViewController *)self.tabBarController;
    p.nextOrientationMask = UIInterfaceOrientationMaskPortrait;
    [super viewDidAppear:YES];

    [self startAnimator];
    // when user goes to their own profile screen via tab menu
    if(self.user==nil || [PFUser.currentUser.username isEqual:self.user[@"username"]]){

        [self.directionsButton setHidden:YES];
        [self.cameraButton setHidden:NO];
        [self.saveButton setHidden:NO];
        [self.captionTextField setUserInteractionEnabled:YES];
        
        if(!self.UserAndUserObjects){
            [self getInfoFromGroupScreen];
        }

        self.user = self.UserAndUserObjects[PFUser.currentUser.username];
        
        if(self.user[@"profileDescription"]){
            self.captionTextField.text = self.user[@"profileDescription"];
        }else{
            self.captionTextField.text = @"Click to set a profile description!";
        }
        
        NSNumber *lat = self.user[@"lat"];
        NSNumber *lon = self.user[@"lon"];
        
        [self setCurrentTownLatitude:lat longitude:lon];
        self.title = self.user[@"username"];
        self.distanceFromUserLabel.text = @"";
        if(self.UsersAndImages[PFUser.currentUser.username]){
            self.profileImage.image = [UIImage imageWithData:self.UsersAndImages[PFUser.currentUser.username]];
        }else{
            self.profileImage.image = [UIImage systemImageNamed:@"person"];
        }
        
    // view for another profile - not own profile
    }else{
        self.title = self.user[@"username"];
        [self.directionsButton setHidden:NO];
        [self.cameraButton setHidden:YES];
        [self.saveButton setHidden:YES];
        [self.captionTextField setUserInteractionEnabled:NO];

        if(self.UsersAndImages[self.user.username]){
            self.profileImage.image = [UIImage imageWithData:self.UsersAndImages[self.user.username]];
        }else{
            self.profileImage.image = [UIImage systemImageNamed:@"person"];
        }
        
        PFUser *currentUser = self.UserAndUserObjects[[NSString stringWithFormat:@"%@", PFUser.currentUser.username]];
        NSNumber *currentUserLat = currentUser[@"lat"];
        NSNumber *currentUserLon = currentUser[@"lon"];
        CLLocation *location1 = [[CLLocation alloc] initWithLatitude:currentUserLat.floatValue longitude: currentUserLon.floatValue];
        
        NSNumber *profileUserLat = self.user[@"lat"];
        NSNumber *profileUserLon = self.user[@"lon"];
        
        if(self.user[@"profileDescription"]){
            self.captionTextField.text = self.user[@"profileDescription"];
        }else{
            self.captionTextField.text = @"This user does not have a profile description - Tell them to set one!";
        }
        
        [self setCurrentTownLatitude:profileUserLat longitude:profileUserLon];
        CLLocation *location2 = [[CLLocation alloc] initWithLatitude:profileUserLat.floatValue longitude:profileUserLon.floatValue];
        CLLocationDistance distance = [location1 distanceFromLocation:location2];
        CLLocationDistance distanceInMiles = distance*0.000621371;
        self.distanceFromUserLabel.text = [NSString stringWithFormat:@"You are %.02f miles away from this user!", distanceInMiles];
    }
}

/*
#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
