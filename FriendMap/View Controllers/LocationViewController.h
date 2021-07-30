//
//  LocationViewController.h
//  FriendMap
//
//  Created by Gildardo Banuelos on 7/30/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LocationViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *arrayOfBusinesses;
@property (nonatomic, strong) NSMutableDictionary *UserAndUserObjects;
@end

NS_ASSUME_NONNULL_END
