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

@interface MapViewController ()

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapView.delegate = self;
    MKCoordinateRegion chicago = MKCoordinateRegionMake(CLLocationCoordinate2DMake(42.238333, -87.998982), MKCoordinateSpanMake(0.1, 0.1));
    [self.mapView setRegion:chicago animated:false];

}

- (void)viewDidAppear:(BOOL)animated{
    [self configureDropDownMenu];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
     MKPinAnnotationView *annotationView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"Pin"];
     if (annotationView == nil) {
         annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Pin"];
         annotationView.canShowCallout = true;
         annotationView.leftCalloutAccessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 50.0, 50.0)];
     }

     UIImageView *imageView = (UIImageView*)annotationView.leftCalloutAccessoryView;
    if(self.UsersAndImages[annotation.title]){
        imageView.image = [UIImage imageWithData:self.UsersAndImages[annotation.title]];
    }else{
        imageView.image = [UIImage systemImageNamed:@"questionmark.square"];
    }
     return annotationView;
 }


- (void)configureDropDownMenu{
    GroupViewController *groupViewController = (GroupViewController *) [[(UINavigationController*)[[self.tabBarController viewControllers] objectAtIndex:0] viewControllers] objectAtIndex:0];
    
    self.arrayOfGroups = groupViewController.arrayOfGroups;
    self.AnnotationArray = [[NSMutableArray alloc] init];
    self.UsersAndImages = groupViewController.UsersAndImages;
    
    
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
        }else{
            [self.mapView removeAnnotations:self.AnnotationArray];
            NSArray *arrayOfMembers = self.arrayOfGroups[indexPath-1][@"members"];
            NSMutableArray *arrayOfUsers = [[NSMutableArray alloc] init];
            for(int i=0; i<arrayOfMembers.count; i++){
                
                PFUser *user = arrayOfMembers[i];
                PFQuery *query = [PFQuery queryWithClassName:@"_User"];

                [query getObjectInBackgroundWithId:user.objectId block:^(PFObject * _Nullable object, NSError * _Nullable error) {
                    if(!error){
                        [arrayOfUsers addObject:object];
                        NSLog(@"%@", object);
                    }
                    if(arrayOfUsers.count == arrayOfMembers.count){
                        for(int i=0; i<arrayOfUsers.count; i++){
                            PFUser *user = arrayOfUsers[i];
                            NSLog(@"%@", user);
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
