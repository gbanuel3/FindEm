//
//  Message.m
//  FriendMap
//
//  Created by Gildardo Banuelos on 7/15/21.
//

#import "Message.h"

@implementation Message

@dynamic text;
@dynamic user;
@dynamic username;
@dynamic date;

+ (nonnull NSString *)parseClassName {
    return @"Message";
}

@end
