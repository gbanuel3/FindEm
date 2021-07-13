//
//  GroupViewController.m
//  FriendMap
//
//  Created by Gildardo Banuelos on 7/13/21.
//
 
#import "GroupViewController.h"
#import "GroupCell.h"
#import <Parse/Parse.h>

@interface GroupViewController () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation GroupViewController

- (void)showPopup{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@""
    message:@"Enter Group Name" preferredStyle:(UIAlertControllerStyleAlert)];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Group name";
        textField.secureTextEntry = NO;
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action){
        // handle response here.
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action){

            PFObject *group = [PFObject objectWithClassName:[NSString stringWithFormat:@"groups"]];
            group[@"name"] = [[alert textFields][0] text];
            group[@"messages"] = [[NSDictionary alloc] init];
            group[@"number_of_members"] = @1;
            group[@"members"] = [[NSArray alloc] initWithObjects:PFUser.currentUser, nil];
//            group[@"image"] =
            [group saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
              if(succeeded){
                  UIAlertController *codeAlert = [UIAlertController alertControllerWithTitle:@"Group Code:" message:[NSString stringWithFormat:@"%@", group.objectId] preferredStyle:(UIAlertControllerStyleAlert)];
                  UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action){}];
                  UIAlertAction *copyCode = [UIAlertAction actionWithTitle:@"Copy to Clipboard" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action){
                      UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                      pasteboard.string = [NSString stringWithFormat:@"%@", group.objectId];
                  }];
                  [codeAlert addAction:copyCode];
                  [codeAlert addAction:confirmAction];
                  [self presentViewController:codeAlert animated:YES completion:^{
                      // optional code for what happens after the alert controller has finished presenting
                  }];
                  
                  
              }else{

                  NSLog(@"Encounted error: %@", error.description);
              }
            }];
    }];

    
    [alert addAction:cancelAction];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:^{
        // optional code for what happens after the alert controller has finished presenting
    }];
}

- (IBAction)onClickJoin:(id)sender{
    
}

- (IBAction)onClickCreate:(id)sender{
    [self showPopup];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GroupCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GroupCell" forIndexPath:indexPath];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 20;
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
