//
//  MapViewController.m
//  FriendMap
//
//  Created by Gildardo Banuelos on 7/13/21.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>
#import <PFNavigationDropdownMenu/PFNavigationDropdownMenu.h>
#import "GroupViewController.h"
#import <Parse/Parse.h>
#import "ProfileViewController.h"
#import "MeetingViewController.h"
#import "LocationViewController.h"
#import "UIImageView+AFNetworking.h"
#import "RootViewController.h"

@interface MapViewController ()

@end

@implementation MapViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.mapView.delegate = self;
    [self.meetButton setHidden:YES];
    [self configureDropDownMenu];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];

}

- (void)forcePortraitOrientation{
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger: UIInterfaceOrientationPortrait] forKey:@"orientation"];
}


- (void)viewDidAppear:(BOOL)animated{
    [self forcePortraitOrientation];
    RootViewController *p = (RootViewController *)self.tabBarController;
    p.nextOrientationMask = UIInterfaceOrientationMaskPortrait;
    [super viewDidAppear:YES];
    [self configureDropDownMenu];
}

- (void)viewDidDisappear:(BOOL)animated{
    [((RootViewController *)self.tabBarController) resetNextOrientationMask];
    [super viewDidDisappear:animated];
}

- (IBAction)findOptimalPlaceToMeet:(id)sender{
    [self performSegueWithIdentifier:@"placeToMeetSegue" sender:nil];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
     MKPinAnnotationView *annotationView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"Pin"];
    
     if(annotationView == nil){
         annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Pin"];
         annotationView.canShowCallout = true;
         annotationView.leftCalloutAccessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 50.0, 50.0)];
         
         UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
                     UITableViewCell *disclosure = [[UITableViewCell alloc] init];
                     [rightButton addSubview:disclosure];
                     rightButton.frame = CGRectMake(0, 0, 25, 25);
                     disclosure.frame = CGRectMake(0, 0, 25, 25);
                     disclosure.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                     disclosure.userInteractionEnabled = NO;
                     annotationView.rightCalloutAccessoryView = rightButton;
     }

    if(self.UsersAndUserObjects[annotation.title]==nil){
        annotationView.pinColor = MKPinAnnotationColorGreen;
        NSURL *url = [NSURL URLWithString:self.imageUrl];
        UIImageView *imageView = (UIImageView*)annotationView.leftCalloutAccessoryView;
        [imageView setImageWithURL:url];
    }else{
        annotationView.pinColor = MKPinAnnotationColorRed;
        UIImageView *imageView = (UIImageView*)annotationView.leftCalloutAccessoryView;
       if(self.UsersAndImages[annotation.title] && self.UsersAndUserObjects!=nil){
           imageView.image = [UIImage imageWithData:self.UsersAndImages[annotation.title]];
       }else{
           imageView.image = [UIImage systemImageNamed:@"person"];
       }
    }
     return annotationView;
 }

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    MKPointAnnotation *annotation = view.annotation;
    if(self.UsersAndUserObjects[annotation.title]==nil){
        PFUser *currentUser = self.UsersAndUserObjects[[NSString stringWithFormat:@"%@", PFUser.currentUser.username]];
        NSNumber *currentUserLat = currentUser[@"lat"];
        NSNumber *currentUserLon = currentUser[@"lon"];
        NSNumber *businessLat = [NSNumber numberWithDouble:annotation.coordinate.latitude];
        NSNumber *businessLon = [NSNumber numberWithDouble:annotation.coordinate.longitude];
        NSString* directionsURL = [NSString stringWithFormat:@"http://maps.apple.com/?saddr=%f,%f&daddr=%f,%f",currentUserLat.floatValue, currentUserLon.floatValue, businessLat.floatValue, businessLon.floatValue];
        if ([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:options:completionHandler:)]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString: directionsURL] options:@{} completionHandler:^(BOOL success) {}];
        } else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString: directionsURL]];
        }
    }else{
        self.user = self.UsersAndUserObjects[annotation.title];
        [self performSegueWithIdentifier:@"mapToProfile" sender:self];
    }
}

- (void)getInfoFromGroupScreen{
    GroupViewController *groupViewController = (GroupViewController *) [[(UINavigationController*)[[self.tabBarController viewControllers] objectAtIndex:0] viewControllers] objectAtIndex:0];
    self.arrayOfGroups = groupViewController.arrayOfGroups;
    self.UsersAndImages = groupViewController.UsersAndImages;
    self.UsersAndUserObjects = groupViewController.UserAndUserObjects;
}

- (void)createPinForUsersInArray: (NSArray *)arrayOfMembers{
    for(int i=0; i<arrayOfMembers.count; i++){
        
        PFUser *user = arrayOfMembers[i];
        PFQuery *query = [PFQuery queryWithClassName:@"_User"];
        
        typeof(self) __weak weakSelf = self;
        [query getObjectInBackgroundWithId:user.objectId block:^(PFObject * _Nullable object, NSError * _Nullable error){
            
            typeof(weakSelf) strongSelf = weakSelf;
            if(!error){
                [strongSelf.arrayOfUsers addObject:object];
            }
            if(strongSelf.arrayOfUsers.count == arrayOfMembers.count){
                for(int i=0; i<strongSelf.arrayOfUsers.count; i++){
                    PFUser *user = strongSelf.arrayOfUsers[i];
                    if(user[@"lat"]!=nil && user[@"lon"]!=nil){
                        NSNumber *lat = user[@"lat"];
                        NSNumber *lon = user[@"lon"];
                        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(lat.floatValue, lon.floatValue);
                        MKPointAnnotation *annotation = [MKPointAnnotation new];
                        annotation.coordinate = coordinate;
                        annotation.title = [NSString stringWithFormat:@"%@", user.username];
                        [strongSelf.mapView addAnnotation:annotation];
                        [strongSelf.mapView viewForAnnotation:annotation];
                        [strongSelf.AnnotationArray addObject:annotation];
                        [strongSelf.mapView showAnnotations:strongSelf.AnnotationArray animated:YES];
                    }
                }
            }
        }];
    }
}

- (void)configureDropDownMenu{
    [self getInfoFromGroupScreen];
    NSMutableArray *items = [[NSMutableArray alloc] initWithObjects:@"No Group Selected...", nil];
    
    for(int i=0; i<self.arrayOfGroups.count; i++){
        [items addObject:self.arrayOfGroups[i][@"name"]];
    }
    
    self.navigationController.navigationBar.translucent = NO;
    
    [UINavigationBar appearance].titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor]};
    [UINavigationBar appearance].barStyle = UIBarStyleDefault;
    
    PFNavigationDropdownMenu *menuView = [[PFNavigationDropdownMenu alloc] initWithFrame:CGRectMake(0, 0, 300, 44)
        title:items.firstObject
        items:items
        containerView:self.view];
    
    menuView.cellHeight = 50;
    menuView.cellBackgroundColor = self.navigationController.navigationBar.barTintColor;
    menuView.cellSelectionColor = [UIColor lightGrayColor];
    menuView.cellTextLabelColor = [UIColor blackColor];
    menuView.cellTextLabelFont = [UIFont fontWithName:@"Avenir-Heavy" size:17];
    menuView.arrowPadding = 15;
    menuView.animationDuration = 0.5f;
    menuView.maskBackgroundColor = [UIColor blackColor];
    menuView.maskBackgroundOpacity = 0.3f;
    
    typeof(self) __weak weakSelf = self;
    menuView.didSelectItemAtIndexHandler = ^(NSUInteger indexPath){
        
        typeof(weakSelf) strongSelf = weakSelf;
        
        if(indexPath==0){
            [strongSelf.meetButton setHidden:YES];
            [strongSelf.mapView removeAnnotations:strongSelf.AnnotationArray];
            [strongSelf.mapView removeAnnotations:strongSelf.showCluster];
        }else{
            [strongSelf.mapView removeAnnotations:strongSelf.AnnotationArray];
            [strongSelf.mapView removeAnnotations:strongSelf.showCluster];
            [strongSelf.meetButton setHidden:NO];
            NSArray *arrayOfMembers = strongSelf.arrayOfGroups[indexPath-1][@"members"];
            strongSelf.arrayOfUsers = [[NSMutableArray alloc] init];
            strongSelf.AnnotationArray = [[NSMutableArray alloc] init];
            [self createPinForUsersInArray:arrayOfMembers];
        }
    };
    self.navigationItem.titleView = menuView;
}

- (void)locationsViewController:(LocationViewController *)controller didPickLocationWithLatitude:(NSNumber *)latitude longitude:(NSNumber *)longitude business:(NSString *)business cluster:(NSMutableArray *)cluster url:(NSURL *)url{
    self.showCluster = [[NSMutableArray alloc] init];
    NSMutableDictionary *usersInCluster = [[NSMutableDictionary alloc] initWithCapacity:200000];
    
    for(PFUser *user in cluster){
        usersInCluster[user.username] = user;
    }
    NSNumber *lat = latitude;
    NSNumber *lon = longitude;
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(lat.floatValue, lon.floatValue);

    MKPointAnnotation *annotation = [MKPointAnnotation new];
    annotation.coordinate = coordinate;
    annotation.title = business;
    self.imageUrl = url;
    
    [self.showCluster addObject:annotation];
    for(MKPointAnnotation *annotation in self.AnnotationArray){
        if(usersInCluster[annotation.title]){
            [self.showCluster addObject:annotation];
        }
    }
    [self.mapView addAnnotation:annotation];
    [self.mapView viewForAnnotation:annotation];
    [self.mapView showAnnotations:self.showCluster animated:YES];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([[segue identifier] isEqualToString:@"mapToProfile"]){
        UINavigationController *navController = [segue destinationViewController];
        ProfileViewController *profileViewController = (ProfileViewController *)([navController viewControllers][0]);
        profileViewController.user = self.user;
        profileViewController.hideCameraButton = YES;
        profileViewController.UsersAndImages = self.UsersAndImages;
        profileViewController.UserAndUserObjects = self.UsersAndUserObjects;
        return;
    }
    if([[segue identifier] isEqualToString:@"placeToMeetSegue"]){
        MeetingViewController *meetingViewController = [segue destinationViewController];
        meetingViewController.arrayOfUsersInGroup = self.arrayOfUsers;
        meetingViewController.UsersAndUserImages = self.UsersAndImages;
        meetingViewController.UsersAndUserObjects = self.UsersAndUserObjects;
        meetingViewController.storedDelegate = self;

        return;
    }
    
}


@end
