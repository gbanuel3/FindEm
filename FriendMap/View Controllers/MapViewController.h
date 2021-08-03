//
//  MapViewController.h
//  FriendMap
//
//  Created by Gildardo Banuelos on 7/13/21.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>
#import "LocationViewController.h"
 

NS_ASSUME_NONNULL_BEGIN

@interface MapViewController : UIViewController <MKMapViewDelegate, LocationViewControllerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) NSMutableArray *arrayOfGroups;
@property (nonatomic, strong) NSMutableArray *AnnotationArray;
@property (nonatomic, strong) NSMutableDictionary *UsersAndImages;
@property (nonatomic, strong) NSMutableDictionary *UsersAndUserObjects;
@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) NSMutableDictionary *results;
@property (nonatomic, strong) NSMutableArray *arrayOfUsers;
@property (nonatomic, strong) NSMutableArray *clusters;
@property (weak, nonatomic) IBOutlet UIButton *meetButton;
@property (nonatomic, strong) NSString *client_key;
@property (nonatomic, strong) NSURL *imageUrl;
@property (nonatomic, strong) NSMutableArray *showCluster;



@end

NS_ASSUME_NONNULL_END
