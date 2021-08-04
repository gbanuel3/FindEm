//
//  ClusterCell.h
//  FriendMap
//
//  Created by Gildardo Banuelos on 7/28/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ClusterCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *membersIncludedLabel;
@property (weak, nonatomic) IBOutlet UIButton *seeMembersButton;

@end

NS_ASSUME_NONNULL_END
