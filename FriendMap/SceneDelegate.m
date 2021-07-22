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
        NSLog(@"Welcome back %@ 😀", user.username);
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *mainNavigationController = [storyboard instantiateViewControllerWithIdentifier:@"MainTabBarController"];
        self.window.rootViewController = mainNavigationController;
    }
}

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
    // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
    // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
    [self stayLoggedIn];
    
    self.shareModel = [LocationManager sharedManager];
    self.shareModel.afterResume = NO;
    
    [self.shareModel addApplicationStatusToPList:@"didFinishLaunchingWithOptions"];

     UIAlertView * alert;
    
    //We have to make sure that the Background App Refresh is enable for the Location updates to work in the background.
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
        
        // When there is a significant changes of the location,
        // The key UIApplicationLaunchOptionsLocationKey will be returned from didFinishLaunchingWithOptions
        // When the app is receiving the key, it must reinitiate the locationManager and get
        // the latest location updates
        
        // This UIApplicationLaunchOptionsLocationKey key enables the location update even when
        // the app has been killed/terminated (Not in th background) by iOS or the user.

//        NSLog(@"UIApplicationLaunchOptionsLocationKey : %@" , [connectionOptions object :UIApplicationLaunchOptionsLocationKey]);
//        if([connectionOptions objectForKey:UIApplicationLaunchOptionsLocationKey]){
            
            // This "afterResume" flag is just to show that he receiving location updates
            // are actually from the key "UIApplicationLaunchOptionsLocationKey"
            self.shareModel.afterResume = YES;

            [self.shareModel startMonitoringLocation];
            [self.shareModel addResumeLocationToPList];
//        }
//        [self applicationDidBecomeActive:self];
    }
}

- (void)sceneDidDisconnect:(UIScene *)scene {
    // Called as the scene is being released by the system.
    // This occurs shortly after the scene enters the background, or when its session is discarded.
    // Release any resources associated with this scene that can be re-created the next time the scene connects.
    // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    NSLog(@"applicationWillTerminate");
    [self.shareModel addApplicationStatusToPList:@"applicationWillTerminate"];
}


- (void)sceneDidBecomeActive:(UIScene *)scene {
    // Called when the scene has moved from an inactive state to an active state.
    // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    NSLog(@"applicationDidBecomeActive");
    [self.shareModel addApplicationStatusToPList:@"applicationDidBecomeActive"];
    self.shareModel.afterResume = NO;
    [self.shareModel startMonitoringLocation];
}


- (void)sceneWillResignActive:(UIScene *)scene {
    // Called when the scene will move from an active state to an inactive state.
    // This may occur due to temporary interruptions (ex. an incoming phone call).
}


- (void)sceneWillEnterForeground:(UIScene *)scene {
    // Called as the scene transitions from the background to the foreground.
    // Use this method to undo the changes made on entering the background.
}


- (void)sceneDidEnterBackground:(UIScene *)scene {
    // Called as the scene transitions from the foreground to the background.
    // Use this method to save data, release shared resources, and store enough scene-specific state information
    // to restore the scene back to its current state.
    NSLog(@"applicationDidEnterBackground");
    [self.shareModel restartMonitoringLocation];
    [self.shareModel addApplicationStatusToPList:@"applicationDidEnterBackground"];
}


@end
