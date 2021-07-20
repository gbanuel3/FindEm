//
//  MessageTableViewCell.h
//  FriendMap
//
//  Created by Gildardo Banuelos on 7/15/21.
//

#import <UIKit/UIKit.h>
#import "MessageTableViewCell.h"
#import "Message.h"

static CGFloat kMessageTableViewCellMinimumHeight = 50.0;
static CGFloat kMessageTableViewCellAvatarHeight = 30.0;

static NSString *MessengerCellIdentifier = @"MessengerCell";
static NSString *AutoCompletionCellIdentifier = @"AutoCompletionCell";

@protocol MessageCellDelegate;

@interface MessageTableViewCell : UITableViewCell

@property (nonatomic, weak) id<MessageCellDelegate> delegate;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *bodyLabel;
@property (nonatomic, strong) UIImageView *thumbnailView;

@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic) BOOL usedForMessage;
@property (nonatomic, strong) Message *message;

+ (CGFloat)defaultFontSize;

@end

@protocol MessageCellDelegate
- (void)MessageCell:(MessageTableViewCell *) messageCell didTap:(Message *)message;
@end
