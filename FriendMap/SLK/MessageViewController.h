//
//  MessageViewController.h
//  FriendMap
//
//  Created by Gildardo Banuelos on 7/15/21.
//

#import "SLKTextViewController.h"
#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface MessageViewController : SLKTextViewController
@property (strong, nonatomic) PFObject *group;
@property (strong, nonatomic) NSMutableArray *messageObjects;
@end

NS_ASSUME_NONNULL_END
