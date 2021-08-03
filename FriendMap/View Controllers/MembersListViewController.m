//
//  MembersListViewController.m
//  FriendMap
//
//  Created by Gildardo Banuelos on 7/14/21.
//

#import "MembersListViewController.h"
#import "MemberCell.h"
#import <Parse/Parse.h>
#import "ProfileViewController.h"

@interface MembersListViewController () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation MembersListViewController

- (IBAction)onClickGroupCode:(id)sender{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = [NSString stringWithFormat:@"%@", self.group.objectId];
    NSLog(@"click detected");
}


- (IBAction)onClickBackground:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;

    if(self.group){
        self.groupCodeField.text = [NSString stringWithFormat:@"Group Code: %@", self.group.objectId];
        [self.groupCodeField setHidden:NO];
    }else{
        [self.groupCodeField setHidden:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    
    if(self.group!=nil){
        self.arrayOfMembers = self.group[@"members"];
        NSLog(@"%@", self.arrayOfMembers);
    }else{
        self.arrayOfMembers = self.cluster;
    }

    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MemberCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MembersCell" forIndexPath:indexPath];
    PFUser *user = self.arrayOfMembers[indexPath.row];
    
    PFQuery *query = [PFQuery queryWithClassName:@"_User"];
    [query whereKey:@"objectId" equalTo:user.objectId];
    [query includeKey:@"all_groups"];
    query.limit = 1;
    typeof(self) __weak weakSelf = self;
    [query findObjectsInBackgroundWithBlock:^(NSArray *returnUser, NSError *error){
        typeof(weakSelf) strongSelf = weakSelf;
        if(returnUser!=nil){
            strongSelf.arrayOfMembers[indexPath.row] = returnUser[0];
            cell.memberNameLabel.text = returnUser[0][@"username"];
            if(strongSelf.UserToImage[returnUser[0][@"username"]]){
                cell.memberProfilePicture.image = [UIImage imageWithData: strongSelf.UserToImage[returnUser[0][@"username"]]];
            }
        }
    }];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrayOfMembers.count;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.user = self.arrayOfMembers[indexPath.row];
    [self performSegueWithIdentifier:@"pfpToProfile" sender:nil];
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([[segue identifier] isEqualToString:@"pfpToProfile"]){
        UINavigationController *navController = [segue destinationViewController];
        ProfileViewController *profileViewController = (ProfileViewController *)([navController viewControllers][0]);
        profileViewController.user = self.user;
        profileViewController.hideCameraButton = YES;
        profileViewController.UsersAndImages = self.UserToImage;
        profileViewController.UserAndUserObjects = self.UserAndUserObjects;
        return;
    }
}


@end
