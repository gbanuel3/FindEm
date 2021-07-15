//
//  GroupChatViewController.m
//  FriendMap
//
//  Created by Gildardo Banuelos on 7/14/21.
//

#import "GroupChatViewController.h"
#import "MembersListViewController.h"
#import "MessageCell.h"

@interface GroupChatViewController () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation GroupChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.title = [NSString stringWithFormat:@"%@", self.group[@"name"]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageCell" forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 5;
}



#pragma mark - Navigation


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([[segue identifier] isEqualToString:@"MembersListSegue"]){
        MembersListViewController *membersListViewController = [segue destinationViewController];
        membersListViewController.group = self.group;
        return;
    }
}


@end
