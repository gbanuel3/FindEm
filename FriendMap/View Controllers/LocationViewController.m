//
//  LocationViewController.m
//  FriendMap
//
//  Created by Gildardo Banuelos on 7/30/21.
//

#import "LocationViewController.h"
#import "LocationCell.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <CoreLocation/CoreLocation.h>
#import <Parse/Parse.h>
#import "UIImageView+AFNetworking.h"
#import "MapViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface LocationViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) MBProgressHUD *hud;

@end

@implementation LocationViewController

- (IBAction)didPressInfo:(id)sender{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[sender tag] inSection:0];
    NSMutableDictionary *business = self.arrayOfBusinesses[indexPath.row];
    NSString *url = business[@"url"];
    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:url]]){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
}

- (IBAction)didPressDirections:(id)sender{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[sender tag] inSection:0];
    NSMutableDictionary *business = self.arrayOfBusinesses[indexPath.row];
    
    PFUser *currentUser = self.UserAndUserObjects[[NSString stringWithFormat:@"%@", PFUser.currentUser.username]];
    NSNumber *currentUserLat = currentUser[@"lat"];
    NSNumber *currentUserLon = currentUser[@"lon"];

    NSNumber *businessLat = business[@"coordinates"][@"latitude"];
    NSNumber *businessLon = business[@"coordinates"][@"longitude"];
    
    NSString* directionsURL = [NSString stringWithFormat:@"http://maps.apple.com/?saddr=%f,%f&daddr=%f,%f",currentUserLat.floatValue, currentUserLon.floatValue, businessLat.floatValue, businessLon.floatValue];
    if([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:options:completionHandler:)]){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: directionsURL] options:@{} completionHandler:^(BOOL success) {}];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: directionsURL]];
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
}

- (void)viewDidAppear:(BOOL)animated{

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    LocationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LocationCell" forIndexPath:indexPath];
    NSMutableDictionary *business = self.arrayOfBusinesses[indexPath.row];
    cell.businessName.text = business[@"name"];
    cell.businessAddress.text = [NSString stringWithFormat:@"%@", business[@"location"][@"display_address"][0]];
    
    NSNumber *businessLat = business[@"coordinates"][@"latitude"];
    NSNumber *businessLon = business[@"coordinates"][@"longitude"];
    if(![businessLat isKindOfClass:[NSNull class]] && ![businessLon isKindOfClass:[NSNull class]]){
        CLLocation *businessLocation = [[CLLocation alloc] initWithLatitude:businessLat.floatValue longitude:businessLon.floatValue];
        PFUser *user = self.UserAndUserObjects[PFUser.currentUser.username];
        NSNumber *userLat = user[@"lat"];
        NSNumber *userLon = user[@"lon"];
        CLLocation *userLocation = [[CLLocation alloc] initWithLatitude:userLat.floatValue longitude:userLon.floatValue];
        const double metersToMilesMultplier = 0.000621371;
        CLLocationDistance distanceInMeters = [businessLocation distanceFromLocation:userLocation];
        float distanceInMiles = distanceInMeters*metersToMilesMultplier;
        cell.businessDistance.text = [NSString stringWithFormat:@"%.02f Miles Away!", distanceInMiles];
    }else{
        cell.businessDistance.text = @"Distance not available";
    }
    
    NSURL *imageURL = [NSURL URLWithString:business[@"image_url"]];
    cell.businessImage.image = nil;
    [cell.businessImage setImageWithURL:imageURL];
    cell.moreInfoButton.tag = indexPath.row;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrayOfBusinesses.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    LocationCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if([cell.businessDistance.text isEqual:@"Distance not available"]){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Could not select location..."
        message:@"Latitude and Longitude are not available at this time!" preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action){}];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:^{
        }];
    }else{
        NSMutableDictionary *business = self.arrayOfBusinesses[indexPath.row];
        NSNumber *businessLat = business[@"coordinates"][@"latitude"];
        NSNumber *businessLon = business[@"coordinates"][@"longitude"];
        [self.delegate locationsViewController:self didPickLocationWithLatitude:businessLat longitude:businessLon business:business[@"name"] cluster:self.cluster url:business[@"image_url"]];
        [self.navigationController popToRootViewControllerAnimated:YES];
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
