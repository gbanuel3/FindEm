//
//  MembersListViewController.h
//  FriendMap
//
//  Created by Gildardo Banuelos on 7/14/21.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface MembersListViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) PFObject *group;
@property (strong, nonatomic) NSArray *arrayOfMembers;

@end

NS_ASSUME_NONNULL_END
