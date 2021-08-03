//
//  MemberCell.h
//  FriendMap
//
//  Created by Gildardo Banuelos on 7/14/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MemberCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *memberNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *memberProfilePicture;

@end

NS_ASSUME_NONNULL_END
