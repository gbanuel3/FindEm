//
//  GroupViewController.h
//  FriendMap
//
//  Created by Gildardo Banuelos on 7/13/21.
//
 
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GroupViewController : UIViewController <CLLocationManagerDelegate>{
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *arrayOfGroups;
@property (weak, nonatomic) IBOutlet UILabel *noGroupLabel;
@property (strong, nonatomic) NSMutableArray *arrayOfUsers;
@property (strong, nonatomic) NSMutableDictionary *UserAndUserObjects;
@property (strong, nonatomic) NSMutableDictionary *UsersAndImages;

@end

NS_ASSUME_NONNULL_END
