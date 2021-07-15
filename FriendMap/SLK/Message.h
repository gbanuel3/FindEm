//
//  Message.h
//  FriendMap
//
//  Created by Gildardo Banuelos on 7/15/21.
//

#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface Message : PFObject<PFSubclassing>

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) NSString *username;


@end

NS_ASSUME_NONNULL_END
