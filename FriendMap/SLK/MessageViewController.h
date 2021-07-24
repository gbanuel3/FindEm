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
@property (strong, nonatomic) NSMutableArray *userObjects;
@property (strong, nonatomic) NSMutableDictionary *UsersAndImages;
@property (strong, nonatomic) PFUser *user;
@property (strong, nonatomic) NSMutableDictionary *UsersAndUserObjects;
@property (strong, nonatomic) NSMutableArray *arrayOfGroups;
@property (strong, nonatomic) NSMutableArray *arrayOfUsers;

@end

NS_ASSUME_NONNULL_END
