//
//  AppDelegate.m
//  FriendMap
//
//  Created by Gildardo Banuelos on 7/12/21.

#import "AppDelegate.h"
#import <Parse/Parse.h>


@interface AppDelegate ()

@end

@implementation AppDelegate


- (void)configureParse{
    ParseClientConfiguration *configuration = [ParseClientConfiguration configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration){
      configuration.applicationId = @"ZRwupPIX5J91iVLNF0bsbHCZNieeAkUGnyobkIKH";
      configuration.clientKey = @"8HZH3Q6BdBPzc1ZOO6q87qHEMU6UmB6seWdpLzzQ";
      configuration.server = @"https://parseapi.back4app.com/";
    }];
    [Parse initializeWithConfiguration:configuration];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    [self configureParse];
    
    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options{
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions{
}


@end
