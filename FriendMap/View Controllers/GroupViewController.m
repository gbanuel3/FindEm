//
//  GroupViewController.m
//  FriendMap
//
//  Created by Gildardo Banuelos on 7/13/21.
//
 
#import "GroupViewController.h"
#import "GroupCell.h"
#import <Parse/Parse.h>
#import "GroupChatViewController.h"
#import "MessageViewController.h"

@interface GroupViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end



@implementation GroupViewController


- (void)showCreatePopup{

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@""
    message:@"Enter Group Name" preferredStyle:(UIAlertControllerStyleAlert)];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Group Name";
        textField.secureTextEntry = NO;
        [textField addTarget:self action:@selector(textDidChange) forControlEvents:UIControlEventValueChanged];
    
    }];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action){
        // handle response here.
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action){
        if([[[alert textFields][0] text] isEqual:@""]){
            UIAlertController *emptyFieldAlert = [UIAlertController alertControllerWithTitle:@"" message:@"Group name cannot be empty!" preferredStyle:(UIAlertControllerStyleAlert)];
            UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action){
                
            }];
            [emptyFieldAlert addAction:confirm];
            [self presentViewController:emptyFieldAlert animated:YES completion:^{
                [self getGroups];
            }];
        }else{
            PFObject *group = [PFObject objectWithClassName:[NSString stringWithFormat:@"groups"]];
            group[@"name"] = [[alert textFields][0] text];
            group[@"messages"] = [[NSDictionary alloc] init];
            group[@"number_of_members"] = @1;
            group[@"members"] = [[NSArray alloc] initWithObjects:PFUser.currentUser, nil];
//            group[@"image"] =
            [group saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
              if(succeeded){
                  PFUser *user = [PFUser currentUser];
                  [user addObject:group forKey:@"all_groups"];
                  [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error){
                      if(succeeded){
                          NSLog(@"Successfully added user to group!");
                      }
                          }];
                  UIAlertController *codeAlert = [UIAlertController alertControllerWithTitle:@"Group Code:" message:[NSString stringWithFormat:@"%@", group.objectId] preferredStyle:(UIAlertControllerStyleAlert)];
                  UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action){}];
                  UIAlertAction *copyCode = [UIAlertAction actionWithTitle:@"Copy to Clipboard" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action){
                      UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                      pasteboard.string = [NSString stringWithFormat:@"%@", group.objectId];
                  }];
                  [codeAlert addAction:copyCode];
                  [codeAlert addAction:confirmAction];
    
                  [self presentViewController:codeAlert animated:YES completion:^{
                      [self getGroups];
                  }];
                  
              }else{

                  NSLog(@"Encounted error: %@", error.description);
              }
            }];
        }

    }];

    
    [alert addAction:cancelAction];
    [alert addAction:okAction];


    [self presentViewController:alert animated:YES completion:^{
        [self getGroups];

    }];
}

- (void)showJoinPopup{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@""
    message:@"Enter Group Code" preferredStyle:(UIAlertControllerStyleAlert)];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Group Code";
        textField.secureTextEntry = NO;
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action){
        // handle response here.
    }];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action){
        bool UserInGroup = NO;
        for(PFObject *group in self.arrayOfGroups){
            if([[[alert textFields][0] text] isEqual:group.objectId]){
                UserInGroup = YES;
                UIAlertController *alreadyInGroupAlert = [UIAlertController alertControllerWithTitle:@"Could not join"
                message:@"User is already in this group" preferredStyle:(UIAlertControllerStyleAlert)];
                UIAlertAction *alreadyInGroupOkAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action){
                    
                }];
                [alreadyInGroupAlert addAction:alreadyInGroupOkAction];
                [self presentViewController:alreadyInGroupAlert animated:YES completion:^{
                    [self getGroups];
                }];
            }
        }
        if(UserInGroup==NO){
            PFQuery *query = [PFQuery queryWithClassName:@"groups"];
            [query whereKey:@"objectId" equalTo:[NSString stringWithFormat:@"%@", [[alert textFields][0] text]]];
            query.limit = 1;
            [query findObjectsInBackgroundWithBlock:^(NSArray *group, NSError *error){
                if(group != nil){
                    if(group.count==0){
                        UIAlertController *groupInvalidAlert = [UIAlertController alertControllerWithTitle:@""
                        message:@"Group Code Invalid" preferredStyle:(UIAlertControllerStyleAlert)];
                        UIAlertAction *groupInvalidOkAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action){
                            
                        }];
                        [groupInvalidAlert addAction:groupInvalidOkAction];
                        [self presentViewController:groupInvalidAlert animated:YES completion:^{
                            [self getGroups];
                        }];
                    }else{
                        PFUser *user = [PFUser currentUser];
                        [user addObject:group[0] forKey:@"all_groups"];
                        [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error){
                            if(succeeded){
                                NSLog(@"Successfully added user to group!");
                                [self getGroups];
                            }
                                }];

                        PFQuery *query = [PFQuery queryWithClassName:@"groups"];
                        [query getObjectInBackgroundWithId:[NSString stringWithFormat:@"%@", [[alert textFields][0] text]] block:^(PFObject *group, NSError *error) {
                                if (!error){
 
                                    [group addObject:[PFUser currentUser] forKey:@"members"];
                                    [group incrementKey:@"number_of_members"];
                                    [group saveInBackground];
                                    [self getGroups];
                                }
                            }];
                    }
                }else{
                    NSLog(@"%@", error.localizedDescription);
                }
            }];
    }
    }];
    
    [alert addAction:cancelAction];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:^{
        [self getGroups];
    }];
    
    
}

- (void)getGroups{

    PFQuery *query = [PFQuery queryWithClassName:@"_User"];
    [query whereKey:@"objectId" equalTo:PFUser.currentUser.objectId];
    [query includeKey:@"all_groups"];
    [query includeKey:@"members"];

    query.limit = 50;
    [query findObjectsInBackgroundWithBlock:^(NSArray *groups, NSError *error){
        if(groups != nil){
            self.arrayOfGroups = groups[0][@"all_groups"];
            if(self.arrayOfGroups==nil){
                [self.tableView setHidden:YES];
                [self.noGroupLabel setHidden:NO];
            }else{
                [self.tableView setHidden:NO];
                [self.noGroupLabel setHidden:YES];
            }

            NSLog(@"Successfully got groups");

        }else{
            NSLog(@"Could not get groups");
        }
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    }];
}

- (IBAction)onClickJoin:(id)sender{
    [self showJoinPopup];
    [self getGroups];
}

- (IBAction)onClickCreate:(id)sender{
    [self showCreatePopup];
    [self getGroups];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self getGroups];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(getGroups) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GroupCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GroupCell" forIndexPath:indexPath];
    PFObject *group = self.arrayOfGroups[indexPath.row];
    cell.groupName.text = group[@"name"];
    cell.groupMembersAmount.text = [NSString stringWithFormat:@"Members: %@", group[@"number_of_members"]];
//    NSLog(@"%@", group);
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrayOfGroups.count;
}


#pragma mark - Navigation


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([[segue identifier] isEqualToString:@"cellSelectedSegue"]){
        GroupCell *tappedCell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
        PFObject *group = self.arrayOfGroups[indexPath.row];
        MessageViewController *messageViewController = [segue destinationViewController];
        messageViewController.group = group;
        return;
    }
}


@end
