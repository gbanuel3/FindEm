//
//  Message.h
//  FriendMap
//
//  Created by Gildardo Banuelos on 7/15/21.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface Message : NSObject

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) PFObject *user;

@end
