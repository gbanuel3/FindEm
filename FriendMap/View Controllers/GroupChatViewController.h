//
//  GroupChatViewController.h
//  FriendMap
//
//  Created by Gildardo Banuelos on 7/14/21.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface GroupChatViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) PFObject *group;
@end

NS_ASSUME_NONNULL_END
