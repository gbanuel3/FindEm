//
//  MeetingViewController.h
//  FriendMap
//
//  Created by Gildardo Banuelos on 7/28/21.
//

#import <UIKit/UIKit.h>
#import "CustomButton.h"
#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface MeetingViewController : UIViewController
@property (weak, nonatomic) IBOutlet CustomButton *calculateButton;
@property (weak, nonatomic) IBOutlet UITextField *distanceField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *meetingLabel;
@property (nonatomic, strong) NSMutableArray *arrayOfUsersInGroup;
@property (nonatomic, strong) PFObject *group;

@end

NS_ASSUME_NONNULL_END
