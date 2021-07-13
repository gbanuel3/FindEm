//
//  GroupViewController.m
//  FriendMap
//
//  Created by Gildardo Banuelos on 7/13/21.
//
 
#import "GroupViewController.h"
#import "GroupCell.h"

@interface GroupViewController () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation GroupViewController

- (IBAction)onClickJoin:(id)sender{
    
}

- (IBAction)onClickCreate:(id)sender{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GroupCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GroupCell" forIndexPath:indexPath];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 20;
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
