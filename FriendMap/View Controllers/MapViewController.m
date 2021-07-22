//
//  MapViewController.m
//  FriendMap
//
//  Created by Gildardo Banuelos on 7/13/21.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>
#import <PFNavigationDropdownMenu/PFNavigationDropdownMenu.h>

@interface MapViewController ()

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    MKCoordinateRegion chicago = MKCoordinateRegionMake(CLLocationCoordinate2DMake(42.238333, -87.998982), MKCoordinateSpanMake(0.1, 0.1));
    [self.mapView setRegion:chicago animated:false];
    
    
    NSArray *items = @[@"Most Popular", @"Latest", @"Trending", @"Nearest", @"Top Picks"];
    self.navigationController.navigationBar.translucent = NO;
//    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0/255.0 green:180/255.0 blue:220/255.0 alpha:1.0];
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
        NSLog(@"Did select item at index: %ld", indexPath);

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
