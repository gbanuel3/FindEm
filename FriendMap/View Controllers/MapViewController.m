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

@interface MapViewController ()

@end

@implementation MapViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.mapView.delegate = self;
    [self.meetButton setHidden:YES];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [self configureDropDownMenu];

}


- (IBAction)findOptimalPlaceToMeet:(id)sender{
    [self performSegueWithIdentifier:@"placeToMeetSegue" sender:nil];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
     MKPinAnnotationView *annotationView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"Pin"];
     if (annotationView == nil) {
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

     UIImageView *imageView = (UIImageView*)annotationView.leftCalloutAccessoryView;
    if(self.UsersAndImages[annotation.title]){
        imageView.image = [UIImage imageWithData:self.UsersAndImages[annotation.title]];
    }else{
        imageView.image = [UIImage systemImageNamed:@"questionmark.square"];
    }
     return annotationView;
 }

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    MKPointAnnotation *annotation = view.annotation;
    self.user = self.UsersAndUserObjects[annotation.title];
    [self performSegueWithIdentifier:@"mapToProfile" sender:self];
}


- (void)configureDropDownMenu{
    GroupViewController *groupViewController = (GroupViewController *) [[(UINavigationController*)[[self.tabBarController viewControllers] objectAtIndex:0] viewControllers] objectAtIndex:0];
    
    self.arrayOfGroups = groupViewController.arrayOfGroups;
    self.UsersAndImages = groupViewController.UsersAndImages;
    self.UsersAndUserObjects = groupViewController.UserAndUserObjects;
    
    
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
    menuView.didSelectItemAtIndexHandler = ^(NSUInteger indexPath){
        NSLog(@"Did select item: %@", items[indexPath]);
        if(indexPath==0){ // No Group Selected...
            [self.mapView removeAnnotations:self.AnnotationArray];
            [self.meetButton setHidden:YES];
        }else{
            [self.meetButton setHidden:NO];
            [self.mapView removeAnnotations:self.AnnotationArray];
            NSArray *arrayOfMembers = self.arrayOfGroups[indexPath-1][@"members"];
            self.arrayOfUsers = [[NSMutableArray alloc] init];
            self.AnnotationArray = [[NSMutableArray alloc] init];
            for(int i=0; i<arrayOfMembers.count; i++){
                
                PFUser *user = arrayOfMembers[i];
                PFQuery *query = [PFQuery queryWithClassName:@"_User"];

                [query getObjectInBackgroundWithId:user.objectId block:^(PFObject * _Nullable object, NSError * _Nullable error) {
                    if(!error){
                        [self.arrayOfUsers addObject:object];

                    }
                    if(self.arrayOfUsers.count == arrayOfMembers.count){
                        for(int i=0; i<self.arrayOfUsers.count; i++){
                            PFUser *user = self.arrayOfUsers[i];

                            if(user[@"lat"]!=nil && user[@"lon"]!=nil){
                                NSNumber *lat = user[@"lat"];
                                NSNumber *lon = user[@"lon"];
                                CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(lat.floatValue, lon.floatValue);
            
                                MKPointAnnotation *annotation = [MKPointAnnotation new];
                                annotation.coordinate = coordinate;
                                annotation.title = [NSString stringWithFormat:@"%@", user.username];
                                
                                [self.mapView addAnnotation:annotation];
                                [self.mapView viewForAnnotation:annotation];
                                [self.AnnotationArray addObject:annotation];
                                [self.mapView showAnnotations:self.AnnotationArray animated:YES];
                                
                            }

                        }
                    }
                }];
            }
            

        }

    };
   
    self.navigationItem.titleView = menuView;
}

- (void)locationsViewController:(LocationViewController *)controller didPickLocationWithLatitude:(NSNumber *)latitude longitude:(NSNumber *)longitude business:(NSString *)business{
    
    NSNumber *lat = latitude;
    NSNumber *lon = longitude;
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(lat.floatValue, lon.floatValue);

    MKPointAnnotation *annotation = [MKPointAnnotation new];
    annotation.coordinate = coordinate;
    annotation.title = business;
    
    [self.mapView addAnnotation:annotation];
    [self.mapView viewForAnnotation:annotation];
    [self.AnnotationArray addObject:annotation];
    [self.mapView showAnnotations:self.AnnotationArray animated:YES];
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
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
