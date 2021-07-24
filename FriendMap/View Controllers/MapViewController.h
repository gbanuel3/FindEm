//
//  MapViewController.h
//  FriendMap
//
//  Created by Gildardo Banuelos on 7/13/21.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MapViewController : UIViewController <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) NSMutableArray *arrayOfGroups;
@property (nonatomic, strong) NSMutableArray *AnnotationArray;
@property (nonatomic, strong) NSMutableDictionary *UsersAndImages;

@end

NS_ASSUME_NONNULL_END
