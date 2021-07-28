//
//  MapViewController.h
//  FriendMap
//
//  Created by Gildardo Banuelos on 7/13/21.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface MapViewController : UIViewController <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) NSMutableArray *arrayOfGroups;
@property (nonatomic, strong) NSMutableArray *AnnotationArray;
@property (nonatomic, strong) NSMutableDictionary *UsersAndImages;
@property (nonatomic, strong) NSMutableDictionary *UsersAndUserObjects;
@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) NSMutableDictionary *results;
@property (nonatomic, strong) NSMutableArray *arrayOfUsers;
@property (nonatomic, strong) NSMutableArray *clusters;


@end

NS_ASSUME_NONNULL_END
