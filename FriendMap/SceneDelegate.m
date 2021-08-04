//
//  SceneDelegate.m
//  FriendMap
//
//  Created by Gildardo Banuelos on 7/12/21.
//

#import "SceneDelegate.h"
#import <Parse/Parse.h>

@interface SceneDelegate ()

@end

@implementation SceneDelegate

- (void) stayLoggedIn{
    PFUser *user = [PFUser currentUser];
    if (user != nil) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *mainNavigationController = [storyboard instantiateViewControllerWithIdentifier:@"MainTabBarController"];
        self.window.rootViewController = mainNavigationController;
    }
}

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    [self stayLoggedIn];
    
    self.shareModel = [LocationManager sharedManager];
    self.shareModel.afterResume = NO;
    
    [self.shareModel addApplicationStatusToPList:@"didFinishLaunchingWithOptions"];

     UIAlertView * alert;
    if ([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusDenied) {
        
        alert = [[UIAlertView alloc]initWithTitle:@""
                                          message:@"The app doesn't work without the Background App Refresh enabled. To turn it on, go to Settings > General > Background App Refresh"
                                         delegate:nil
                                cancelButtonTitle:@"Ok"
                                otherButtonTitles:nil, nil];
        [alert show];
        
    } else if ([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusRestricted) {

        alert = [[UIAlertView alloc]initWithTitle:@""
                                          message:@"The functions of this app are limited because the Background App Refresh is disable."
                                         delegate:nil
                                cancelButtonTitle:@"Ok"
                                otherButtonTitles:nil, nil];
        [alert show];
        
    }else{
            self.shareModel.afterResume = YES;

            [self.shareModel startMonitoringLocation];
            [self.shareModel addResumeLocationToPList];
//        }

    }
}

- (void)sceneDidDisconnect:(UIScene *)scene {
    [self.shareModel addApplicationStatusToPList:@"applicationWillTerminate"];
}


- (void)sceneDidBecomeActive:(UIScene *)scene {
    [self.shareModel addApplicationStatusToPList:@"applicationDidBecomeActive"];
    self.shareModel.afterResume = NO;
    [self.shareModel startMonitoringLocation];
}


- (void)sceneDidEnterBackground:(UIScene *)scene {
    [self.shareModel restartMonitoringLocation];
    [self.shareModel addApplicationStatusToPList:@"applicationDidEnterBackground"];
}


@end
