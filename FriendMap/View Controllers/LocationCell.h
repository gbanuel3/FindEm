//
//  LocationCell.h
//  FriendMap
//
//  Created by Gildardo Banuelos on 7/30/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LocationCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *businessImage;
@property (weak, nonatomic) IBOutlet UILabel *businessName;
@property (weak, nonatomic) IBOutlet UILabel *businessAddress;
@property (weak, nonatomic) IBOutlet UILabel *businessDistance;
@property (weak, nonatomic) IBOutlet UIButton *directionsButton;
@property (weak, nonatomic) IBOutlet UIButton *moreInfoButton;

@end

NS_ASSUME_NONNULL_END
