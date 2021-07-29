//
//  MeetingViewController.m
//  FriendMap
//
//  Created by Gildardo Banuelos on 7/28/21.
//

#import "MeetingViewController.h"
#import "ClusterCell.h"

@interface MeetingViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@end

@implementation MeetingViewController

- (double) distanceBetweenUsers:(PFUser *)user1 user2:(PFUser *) user2{
    const double metersToMilesMultplier = 0.000621371;
    NSNumber *user1Lat = user1[@"lat"];
    NSNumber *user1Lon = user1[@"lon"];
    CLLocation *location1 = [[CLLocation alloc] initWithLatitude:user1Lat.floatValue longitude: user1Lon.floatValue];
    
    NSNumber *user2Lat = user2[@"lat"];
    NSNumber *user2Lon = user2[@"lon"];
    CLLocation *location2 = [[CLLocation alloc] initWithLatitude:user2Lat.floatValue longitude:user2Lon.floatValue];
    CLLocationDistance distanceInMeters = [location1 distanceFromLocation:location2];
    CLLocationDistance distanceInMiles = distanceInMeters*metersToMilesMultplier;
    return distanceInMiles;
}

- (void)clusterLocations:(NSNumber *)distance{
    NSMutableArray *AllPins = [[NSMutableArray alloc] initWithArray:self.arrayOfUsersInGroup];
    self.arrayOfClusters = [[NSMutableArray alloc] init];
    
    while(AllPins.count > 0){
        
        NSMutableArray *temporaryCluster = [[NSMutableArray alloc] init];
        PFUser *user1 = [AllPins firstObject];
        [AllPins removeObjectAtIndex:0];
        
        for(int i=0; i<AllPins.count; i++){
            PFUser *user2 = AllPins[i];
            NSNumber *dist = [NSNumber numberWithFloat:[self distanceBetweenUsers:user1 user2:user2]];
            if(dist.doubleValue < distance.doubleValue){
                [temporaryCluster addObject:AllPins[i]];
                [AllPins removeObjectAtIndex:i];
            }
        }
        
        [temporaryCluster addObject:user1];
        [self.arrayOfClusters addObject:temporaryCluster];

    }
}

- (IBAction)onClickCalculate:(id)sender{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *distance = [formatter numberFromString:self.distanceField.text];
    [self.view endEditing:YES];
    if(distance==nil){
        [self.tableView setHidden:YES];
        UIAlertController *notValidNumberAlert = [UIAlertController alertControllerWithTitle:@""
        message:@"You must enter a valid number!" preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction *notValidNumberOkAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action){
            
        }];
        [notValidNumberAlert addAction:notValidNumberOkAction];
        [self presentViewController:notValidNumberAlert animated:YES completion:^{
        }];
    }else{
        [self.tableView setHidden:NO];
        [self clusterLocations:distance];
        NSLog(@"%@", self.arrayOfClusters);
    }
}

-(void)textFieldDidChange :(UITextField *) textField{
    [self.tableView setHidden:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.distanceField.delegate = self;
    [self.distanceField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    [self.tableView setHidden:YES];
    

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self.calculateButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    return YES;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ClusterCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ClusterCell" forIndexPath:indexPath];
    NSMutableArray *cluster = self.arrayOfClusters;
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
