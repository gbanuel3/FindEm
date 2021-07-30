//
//  MeetingViewController.m
//  FriendMap
//
//  Created by Gildardo Banuelos on 7/28/21.
//

#import "MeetingViewController.h"
#import "ClusterCell.h"
#import "MembersListViewController.h"
#import "LocationViewController.h"

@interface MeetingViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@end

@implementation MeetingViewController

- (void)getClientKey{
    NSString *path = [[NSBundle mainBundle] pathForResource: @"Keys" ofType: @"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: path];
    NSString *clientKey= [dict objectForKey: @"API_Client"];
    self.API_Key = clientKey;
    
}


- (void)getLocationsFromCoordinateLatitude:(NSNumber *)latitude longitude:(NSNumber *) longitude{
    NSString *baseURLString = [NSString stringWithFormat:@"https://api.yelp.com/v3/businesses/search?latitude=%@&longitude=%@&sort_by=distance", latitude, longitude];
    
    NSURL *url = [NSURL URLWithString:baseURLString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:[NSString stringWithFormat:@"Bearer %@", self.API_Key] forHTTPHeaderField:@"Authorization"];

    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(data){
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            self.arrayOfBusinesses = [responseDictionary valueForKeyPath:@"businesses"];
            [self performSegueWithIdentifier:@"LocationSegue" sender:nil];
        }else{
            NSLog(@"%@", error.localizedDescription);
        }
    }];
    [task resume];
}

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
        NSMutableArray *ObjectsToRemove = [[NSMutableArray alloc] init];
        PFUser *user1 = [AllPins firstObject];
        [AllPins removeObjectAtIndex:0];
        
        for(int i=0; i<AllPins.count; i++){
            PFUser *user2 = AllPins[i];
            NSNumber *dist = [NSNumber numberWithFloat:[self distanceBetweenUsers:user1 user2:user2]];
            if(dist.doubleValue < distance.doubleValue){
                [temporaryCluster addObject:AllPins[i]];
                [ObjectsToRemove addObject:AllPins[i]];
            }
        }
        
        for(int i=0; i<ObjectsToRemove.count; i++){
            [AllPins removeObject: ObjectsToRemove[i]];
        }
        
        [temporaryCluster addObject:user1];
        [self.arrayOfClusters addObject:temporaryCluster];

    }
}

- (CLLocationCoordinate2D)CalculateMidpoint:(NSMutableArray *)users{
    double sumOfX = 0;
    double sumOfY = 0;
    double sumOfZ = 0;
    
    for(PFUser *user in users){
        double x = cos([user[@"lat"] floatValue]*(M_PI/180)) * cos([user[@"lon"] floatValue]*(M_PI/180));
        double y = cos([user[@"lat"] floatValue]*(M_PI/180)) * sin([user[@"lon"] floatValue]*(M_PI/180));
        double z = sin([user[@"lat"] floatValue]*(M_PI/180));
        
        sumOfX += x;
        sumOfY += y;
        sumOfZ += z;
    }
    double avgOfX = sumOfX/users.count;
    double avgOfY = sumOfY/users.count;
    double avgOfZ = sumOfZ/users.count;
    
    double centerLon = atan2(avgOfY, avgOfX)*(180/M_PI);
    double centerLat = atan2(avgOfZ, sqrt(avgOfX*avgOfX + avgOfY*avgOfY))*(180/M_PI);
    
    NSLog(@"Lat: %f == Lon: %f", centerLat, centerLon);
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(centerLat, centerLon);
    return coordinate;
    
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
        self.arrayOfClusters = [self.arrayOfClusters sortedArrayUsingComparator:^NSComparisonResult(NSMutableArray *a, NSMutableArray *b) {
            return a.count < b.count;
        }];
        [self.tableView reloadData];
        
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
    
    [self getClientKey];
    
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
    
    NSMutableArray *cluster = self.arrayOfClusters[indexPath.row];
    CLLocationCoordinate2D coordinate = [self CalculateMidpoint:cluster];
    
    CLGeocoder *ceo = [[CLGeocoder alloc]init];
    CLLocation *loc = [[CLLocation alloc]initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    [ceo reverseGeocodeLocation: loc completionHandler:
     ^(NSArray *placemarks, NSError *error) {
         CLPlacemark *placemark = [placemarks objectAtIndex:0];

        NSString *address = [NSString stringWithFormat:@"%@ %@, %@", [placemark.addressDictionary valueForKey:@"City"], [placemark.addressDictionary valueForKey:@"State"], [placemark.addressDictionary valueForKey:@"Country"]];
        cell.addressLabel.text = address;
        cell.membersIncludedLabel.text = [NSString stringWithFormat:@"Members Included: %lu", (unsigned long)cluster.count];
        cell.seeMembersButton.tag = indexPath.row;
     }];

    return cell;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrayOfClusters.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableArray *cluster = self.arrayOfClusters[indexPath.row];
    CLLocationCoordinate2D coordinate = [self CalculateMidpoint:cluster];
    [self getLocationsFromCoordinateLatitude:[NSNumber numberWithDouble:coordinate.latitude] longitude:[NSNumber numberWithFloat:coordinate.longitude]];
}
 

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([[segue identifier] isEqualToString:@"clusterToMembersSegue"]){
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[sender tag] inSection:0];
        NSMutableArray *cluster = self.arrayOfClusters[indexPath.row];
        MembersListViewController *membersListViewController = [segue destinationViewController];
        membersListViewController.UserToImage = self.UsersAndUserImages;
        membersListViewController.UserAndUserObjects = self.UsersAndUserObjects;
        membersListViewController.cluster = cluster;
        return;
    }
    if([[segue identifier] isEqualToString:@"LocationSegue"]){
        LocationViewController *locationViewController = [segue destinationViewController];
        locationViewController.arrayOfBusinesses = self.arrayOfBusinesses;
        locationViewController.UserAndUserObjects = self.UsersAndUserObjects;
        locationViewController.delegate = self.storedDelegate;
    }
}


@end
