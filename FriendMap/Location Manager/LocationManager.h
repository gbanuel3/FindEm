//
//  LocationManager.h
//  FriendMap
//
//  Created by Gildardo Banuelos on 7/22/21.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@interface LocationManager : NSObject

@property (nonatomic) CLLocationManager * anotherLocationManager;
@property (nonatomic) CLLocationCoordinate2D myLastLocation;
@property (nonatomic) CLLocationAccuracy myLastLocationAccuracy;
@property (nonatomic) CLLocationCoordinate2D myLocation;
@property (nonatomic) CLLocationAccuracy myLocationAccuracy;
@property (nonatomic) NSMutableDictionary *myLocationDictInPlist;
@property (nonatomic) NSMutableArray *myLocationArrayInPlist;
@property (nonatomic) BOOL afterResume;

+ (id)sharedManager;
- (void)startMonitoringLocation;
- (void)restartMonitoringLocation;
- (void)addResumeLocationToPList;
- (void)addLocationToPList:(BOOL)fromResume;
- (void)addApplicationStatusToPList:(NSString*)applicationStatus;

@end

NS_ASSUME_NONNULL_END
