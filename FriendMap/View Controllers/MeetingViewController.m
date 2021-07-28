//
//  MeetingViewController.m
//  FriendMap
//
//  Created by Gildardo Banuelos on 7/28/21.
//

#import "MeetingViewController.h"
#import "ClusterCell.h"

@interface MeetingViewController () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation MeetingViewController

- (IBAction)onClickCalculate:(id)sender{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
//    [self ]

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ClusterCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ClusterCell" forIndexPath:indexPath];
    
    return cell;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 5;
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
