//
//  GroupViewController.h
//  FriendMap
//
//  Created by Gildardo Banuelos on 7/13/21.
//
 
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GroupViewController : UIViewController <CLLocationManagerDelegate>
{
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *arrayOfGroups;
@property (weak, nonatomic) IBOutlet UILabel *noGroupLabel;


@end

NS_ASSUME_NONNULL_END
