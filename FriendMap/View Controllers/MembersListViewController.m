//
//  MembersListViewController.m
//  FriendMap
//
//  Created by Gildardo Banuelos on 7/14/21.
//

#import "MembersListViewController.h"
#import "MemberCell.h"
#import <Parse/Parse.h>

@interface MembersListViewController () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation MembersListViewController

- (IBAction)onClickBackground:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.arrayOfMembers = self.group[@"members"];
//    NSLog(@"%@", self.group);
}

- (void)viewDidAppear:(BOOL)animated{
    self.arrayOfMembers = self.group[@"members"];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MemberCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MembersCell" forIndexPath:indexPath];
    PFUser *user = self.arrayOfMembers[indexPath.row];
    
    PFQuery *query = [PFQuery queryWithClassName:@"_User"];
    [query whereKey:@"objectId" equalTo:user.objectId];
    [query includeKey:@"all_groups"];

    query.limit = 1;
    [query findObjectsInBackgroundWithBlock:^(NSArray *returnUser, NSError *error){
        if(returnUser != nil){
            cell.memberNameLabel.text = returnUser[0][@"username"];

            NSLog(@"Successfully got user");

        }else{
            NSLog(@"Could not get user");
        }
    }];
    
//    cell.memberNameLabel.text = user.username;
//    cell.memberProfilePicture.text = [NSString stringWithFormat:@"Members: %@", group[@"number_of_members"]];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrayOfMembers.count;
    
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
