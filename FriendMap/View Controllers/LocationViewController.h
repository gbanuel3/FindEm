//
//  LocationViewController.h
//  FriendMap
//
//  Created by Gildardo Banuelos on 7/30/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class LocationViewController;
@protocol LocationViewControllerDelegate
- (void)locationsViewController:(LocationViewController *)controller didPickLocationWithLatitude:(NSNumber *)latitude longitude:(NSNumber *)longitude business:(NSString *)business cluster:(NSMutableArray *)cluster url:(NSURL *)url;

@end

@interface LocationViewController : UIViewController

@property (weak, nonatomic) id<LocationViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *arrayOfBusinesses;
@property (nonatomic, strong) NSMutableDictionary *UserAndUserObjects;
@property (nonatomic, strong) NSMutableArray *cluster;

@end

NS_ASSUME_NONNULL_END
