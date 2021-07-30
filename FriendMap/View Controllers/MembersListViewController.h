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
@property (strong, nonatomic) NSMutableArray *arrayOfMembers;
@property (weak, nonatomic) IBOutlet UITextView *groupCodeField;
@property (weak, nonatomic) PFUser *user;
@property (strong, nonatomic) NSMutableDictionary *UserToImage;
@property (strong, nonatomic) NSMutableDictionary *UserAndUserObjects;
@property (nonatomic, strong) NSMutableArray *cluster;

@end

NS_ASSUME_NONNULL_END
