//
//  MessageViewController.m
//  FriendMap
//
//  Created by Gildardo Banuelos on 7/15/21.
//
#import "MembersListViewController.h"
#import "MessageViewController.h"
#import "MessageTableViewCell.h"
#import "MessageTextView.h"
#import "TypingIndicatorView.h"
#import "Message.h"
#import <DateTools/DateTools.h>
#import "ProfileViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "MapViewController.h"
#import "GroupViewController.h"


#define DEBUG_CUSTOM_TYPING_INDICATOR 0
#define DEBUG_CUSTOM_BOTTOM_VIEW 0

@interface MessageViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, MessageCellDelegate>

@property (nonatomic, strong) NSMutableArray *messages;

@property (nonatomic, strong) NSArray *users;
@property (nonatomic, strong) NSArray *channels;
@property (nonatomic, strong) NSArray *emojis;
@property (nonatomic, strong) NSArray *commands;

@property (nonatomic, strong) NSArray *searchResult;

@property (nonatomic, strong) UIWindow *pipWindow;

@property (nonatomic, weak) Message *editingMessage;

@property (strong, nonatomic) UIBarButtonItem *refreshItem;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property bool isAnimating;
@property (strong, nonatomic) MBProgressHUD *hud;

@end

@implementation MessageViewController

- (instancetype)init
{
    self = [super initWithTableViewStyle:UITableViewStylePlain];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

+(UITableViewStyle)tableViewStyleForCoder:(NSCoder *)decoder{
    return UITableViewStylePlain;
}

- (void)commonInit{
    [[NSNotificationCenter defaultCenter] addObserver:self.tableView selector:@selector(reloadData) name:UIContentSizeCategoryDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textInputbarDidMove:) name:SLKTextInputbarDidMoveNotification object:nil];
    

    [self registerClassForTextView:[MessageTextView class]];
    
#if DEBUG_CUSTOM_TYPING_INDICATOR
    [self registerClassForTypingIndicatorView:[TypingIndicatorView class]];
#endif
}


#pragma mark - View lifecycle



- (void)MessageCell:(MessageTableViewCell *)messageCell didTap:(Message *)message{
    [self performSegueWithIdentifier:@"chatToProfile" sender:message];
}

- (void)viewDidLoad{
    
    [super viewDidLoad];
    
    self.isAnimating = NO;
    [self configureDataSource];
    [self configureActionItems];

    
    self.bounces = YES;
    self.shakeToClearEnabled = YES;
    self.keyboardPanningEnabled = YES;
    self.shouldScrollToBottomAfterKeyboardShows = NO;
    self.inverted = YES;
    
    [self.leftButton setImage:[UIImage systemImageNamed:@"arrow.right.doc.on.clipboard"] forState:UIControlStateNormal];
    [self.leftButton setTintColor:[UIColor grayColor]];
    
    [self.rightButton setTitle:NSLocalizedString(@"Send", nil) forState:UIControlStateNormal];
    
    self.textInputbar.autoHideRightButton = YES;
    self.textInputbar.maxCharCount = 256;
    self.textInputbar.counterStyle = SLKCounterStyleSplit;
    self.textInputbar.counterPosition = SLKCounterPositionTop;
    
    [self.textInputbar.editorTitle setTextColor:[UIColor darkGrayColor]];
    [self.textInputbar.editorLeftButton setTintColor:[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1.0]];
    [self.textInputbar.editorRightButton setTintColor:[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1.0]];
    
#if DEBUG_CUSTOM_BOTTOM_VIEW
    
    UIView *bannerView = [UIView new];
    bannerView.translatesAutoresizingMaskIntoConstraints = NO;
    bannerView.backgroundColor = [UIColor blueColor];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(bannerView);
    
    [self.textInputbar.contentView addSubview:bannerView];
    [self.textInputbar.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[bannerView]|" options:0 metrics:nil views:views]];
    [self.textInputbar.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[bannerView(40)]|" options:0 metrics:nil views:views]];
#endif
    
#if !DEBUG_CUSTOM_TYPING_INDICATOR
    self.typingIndicatorView.canResignByTouch = YES;
#endif
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[MessageTableViewCell class] forCellReuseIdentifier:MessengerCellIdentifier];
    
    [self.autoCompletionView registerClass:[MessageTableViewCell class] forCellReuseIdentifier:AutoCompletionCellIdentifier];
    [self registerPrefixesForAutoCompletion:@[@"@", @"#", @":", @"+:", @"/"]];
    
    [self.textView registerMarkdownFormattingSymbol:@"*" withTitle:@"Bold"];
    [self.textView registerMarkdownFormattingSymbol:@"_" withTitle:@"Italics"];
    [self.textView registerMarkdownFormattingSymbol:@"~" withTitle:@"Strike"];
    [self.textView registerMarkdownFormattingSymbol:@"`" withTitle:@"Code"];
    [self.textView registerMarkdownFormattingSymbol:@"```" withTitle:@"Preformatted"];
    [self.textView registerMarkdownFormattingSymbol:@">" withTitle:@"Quote"];
    

}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(configureDataSource) userInfo:nil repeats:YES];


}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.timer invalidate];
}




#pragma mark - Example's Configuration

- (void)configureDataSource{
    
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.mode = MBProgressHUDModeIndeterminate;
    self.hud.label.text = @"Loading...";
    self.isAnimating = YES;
    
    self.messageObjects = [[NSMutableArray alloc] init];
    self.userObjects = [[NSMutableArray alloc] init];
    self.arrayOfUsers = [[NSMutableArray alloc] init];
    self.UsersAndUserObjects = [[NSMutableDictionary alloc] initWithCapacity:200000];
    self.UsersAndImages = [[NSMutableDictionary alloc] initWithCapacity:200000];
    
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_enter(group);
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        PFQuery *UsersQuery = [PFQuery queryWithClassName:@"_User"];
        typeof(self) __weak weakSelf = self;
        [UsersQuery findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error){
            typeof(weakSelf) strongSelf = weakSelf;
            if(!error){
                strongSelf.arrayOfUsers = users;
                int countOfPfps = 0;
                for(PFUser *user in users){
                    if(user[@"profile_picture"]){
                        countOfPfps++;
                    }
                }
                for(PFUser *user in users){
                    [strongSelf.UsersAndUserObjects setValue:user forKey:user.username];
                        [user[@"profile_picture"] getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error){
                            if(!error){
                                [strongSelf.UsersAndImages setValue:imageData forKey:user.username];
                                if(strongSelf.UsersAndImages.count == countOfPfps){
                                    dispatch_group_leave(group);
                                }
                            }
                        }];
                }
                
            }
        }];
    });
    
    dispatch_group_enter(group);
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        typeof(self) __weak weakSelf = self;
        PFQuery *query = [PFQuery queryWithClassName:@"groups"];
        [query getObjectInBackgroundWithId:self.group.objectId block:^(PFObject * _Nullable object, NSError * _Nullable error){
            typeof(weakSelf) strongSelf = weakSelf;
            if(!error){
                strongSelf.group = object;
                strongSelf.messages = strongSelf.group[@"messages"];
                if(strongSelf.messages.count == 0){
                    dispatch_group_leave(group);
                }
                for(int index=0; index<strongSelf.messages.count; index++){
                    Message *message = [strongSelf.messages objectAtIndex:index];
                    PFQuery *query = [PFQuery queryWithClassName:@"Message"];
                    [query getObjectInBackgroundWithId:message.objectId block:^(PFObject *messageObject, NSError *error){
                        if(messageObject != nil){
                            [strongSelf.messageObjects addObject:messageObject];
                        }
                        if(strongSelf.messageObjects.count == strongSelf.messages.count){
                            dispatch_group_leave(group);
                        }
                    }];
                
                }
                
            }
        }];
    });
    
    typeof(self) __weak weakSelf = self;
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.messageObjects = [strongSelf.messageObjects sortedArrayUsingComparator:^NSComparisonResult(Message *a, Message *b) {
                return [b.createdAt compare:a.createdAt];
            }];

                [strongSelf.hud hideAnimated:YES];
                strongSelf.isAnimating = NO;
        
            [strongSelf.tableView reloadData];


    });
}

- (void)configureActionItems
{
    UIBarButtonItem *arrowItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icn_arrow_down"] style:UIBarButtonItemStylePlain target:self action:@selector(hideOrShowTextInputbar:)];
    
     self.refreshItem = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"arrow.clockwise"] style:UIBarButtonItemStylePlain target:self action:@selector(refreshMessageFeed:)];
    
    UIBarButtonItem *uploadPFP = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"photo.fill.on.rectangle.fill"] style:UIBarButtonItemStylePlain target:self action:@selector(changeGroupImage:)];
    
    UIBarButtonItem *introduction = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"figure.wave"]style:UIBarButtonItemStylePlain target:self action:@selector(fillWithText:)];
    
    UIBarButtonItem *showMembers = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"person.2.fill"] style:UIBarButtonItemStylePlain target:self action:@selector(showMembersButton:)];
    
    self.navigationItem.rightBarButtonItems = @[arrowItem, showMembers, self.refreshItem, introduction, uploadPFP];
}


#pragma mark - Action Methods

- (void)hideOrShowTextInputbar:(id)sender{
    BOOL hide = !self.textInputbarHidden;
    
    UIImage *image = hide ? [UIImage imageNamed:@"icn_arrow_up"] : [UIImage imageNamed:@"icn_arrow_down"];
    UIBarButtonItem *buttonItem = (UIBarButtonItem *)sender;
    
    [self setTextInputbarHidden:hide animated:YES];
    
    [buttonItem setImage:image];
}

- (void)fillWithText:(id)sender{
    self.textView.text = [NSString stringWithFormat:@"Hello everyone! My name is %@. It is a pleasure to be here!", PFUser.currentUser.username];
}

- (void)changeGroupImage:(id)sender{
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;
    imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

    [self presentViewController:imagePickerVC animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];

    NSData *imageData = UIImagePNGRepresentation(editedImage);
    PFFileObject *imageFile = [PFFileObject fileObjectWithName:@"image.png" data:imageData];
    PFQuery *query = [PFQuery queryWithClassName:@"groups"];
    [query getObjectInBackgroundWithId:self.group.objectId block:^(PFObject *group, NSError *error){
            if (!error){
                [group setObject:imageFile forKey:@"image"];
                [group saveInBackground];
            }
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    

}

- (void)refreshMessageFeed:(id)sender{
    if(self.isAnimating==YES){
        [self.hud hideAnimated:YES];
        self.isAnimating = NO;
    }
    [self.refreshItem setAccessibilityRespondsToUserInteraction:NO];
    [self configureDataSource];
    [self.refreshItem setAccessibilityRespondsToUserInteraction:YES];

}

- (void)showMembersButton:(id)sender{
    [self performSegueWithIdentifier:@"showMembersSegue" sender:nil];
}



- (void)textInputbarDidMove:(NSNotification *)note{
    return;
}


#pragma mark - Overriden Methods

- (BOOL)ignoreTextInputbarAdjustment{
    return [super ignoreTextInputbarAdjustment];
}

- (BOOL)forceTextInputbarAdjustmentForResponder:(UIResponder *)responder{
    if ([responder isKindOfClass:[UIAlertController class]]){
        return YES;
    }
    return SLK_IS_IPAD;
}

- (void)textWillUpdate{
    [super textWillUpdate];
}

- (void)textDidUpdate:(BOOL)animated{
    [super textDidUpdate:animated];
}

- (void)didPressLeftButton:(id)sender{
    [super didPressLeftButton:sender];
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    self.textView.text = pasteboard.string;
}

- (void)didPressRightButton:(id)sender{
    [self.textView refreshFirstResponder];
    
    Message *message = [Message new];
    message.username = PFUser.currentUser.username;
    message.text = [self.textView.text copy];
    message.user = PFUser.currentUser;
    message.date = [NSDate date];
    
    typeof(self) __weak weakSelf = self;
    PFQuery *query = [PFQuery queryWithClassName:@"groups"];
    [query getObjectInBackgroundWithId:self.group.objectId block:^(PFObject *group, NSError *error){
        typeof(weakSelf) strongSelf = weakSelf;
        if (!error){
            [group addObject:message forKey:@"messages"];
            [group saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if(succeeded){
                    if(strongSelf.isAnimating==YES){
                        [strongSelf.hud hideAnimated:YES];
                        strongSelf.isAnimating = NO;
                    }
                    [strongSelf.refreshItem setAccessibilityRespondsToUserInteraction:NO];
                    [strongSelf configureDataSource];
                    [strongSelf.refreshItem setAccessibilityRespondsToUserInteraction:YES];
                }
            }];

        }
    }];
    [super didPressRightButton:sender];
}

- (void)didPressArrowKey:(UIKeyCommand *)keyCommand{
    [super didPressArrowKey:keyCommand];
}

- (NSString *)keyForTextCaching{
    return [[NSBundle mainBundle] bundleIdentifier];
}

- (BOOL)canPressRightButton{
    return [super canPressRightButton];
}

- (BOOL)shouldProcessTextForAutoCompletion{
    return [super shouldProcessTextForAutoCompletion];
}

- (BOOL)shouldDisableTypingSuggestionForAutoCompletion{
    return [super shouldDisableTypingSuggestionForAutoCompletion];
}
    
- (void)didChangeAutoCompletionPrefix:(NSString *)prefix andWord:(NSString *)word{
    NSArray *array = nil;
    self.searchResult = nil;
    if([prefix isEqualToString:@"@"]){
        if(word.length>0){
            array = [self.users filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self BEGINSWITH[c] %@", word]];
        }else{
            array = self.users;
        }
    }else if([prefix isEqualToString:@"#"] && word.length>0){
        array = [self.channels filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self BEGINSWITH[c] %@", word]];
    }else if(([prefix isEqualToString:@":"] || [prefix isEqualToString:@"+:"]) && word.length>1){
        array = [self.emojis filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self BEGINSWITH[c] %@", word]];
    }else if([prefix isEqualToString:@"/"] && self.foundPrefixRange.location == 0){
        if(word.length>0){
            array = [self.commands filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self BEGINSWITH[c] %@", word]];
        }else{
            array = self.commands;
        }
    }
    
    if (array.count>0){
        array = [array sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    }
    
    self.searchResult = [[NSMutableArray alloc] initWithArray:array];
    BOOL show = (self.searchResult.count>0);
    [self showAutoCompletionView:show];
}

- (CGFloat)heightForAutoCompletionView{
    CGFloat cellHeight = [self.autoCompletionView.delegate tableView:self.autoCompletionView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    return cellHeight*self.searchResult.count;
}


#pragma mark - SLKTextViewDelegate Methods

- (BOOL)textView:(SLKTextView *)textView shouldOfferFormattingForSymbol:(NSString *)symbol{
    if([symbol isEqualToString:@">"]){
        
        NSRange selection = textView.selectedRange;
        if(selection.location==0 && selection.length>0){
            return YES;
        }
        NSString *prevString = [textView.text substringWithRange:NSMakeRange(selection.location-1, 1)];
        if([[NSCharacterSet newlineCharacterSet] characterIsMember:[prevString characterAtIndex:0]]){
            return YES;
        }
        return NO;
    }
    return [super textView:textView shouldOfferFormattingForSymbol:symbol];
}

- (BOOL)textView:(SLKTextView *)textView shouldInsertSuffixForFormattingWithSymbol:(NSString *)symbol prefixRange:(NSRange)prefixRange{
    if([symbol isEqualToString:@">"]){
        return NO;
    }
    return [super textView:textView shouldInsertSuffixForFormattingWithSymbol:symbol prefixRange:prefixRange];
}

#pragma mark - UITextViewDelegate Methods

- (BOOL)textView:(SLKTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    return [super textView:textView shouldChangeTextInRange:range replacementText:text];
}


#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if([tableView isEqual:self.tableView]){
        return self.messages.count;
    }else{
        return self.searchResult.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if([tableView isEqual:self.tableView]){
        return [self messageCellForRowAtIndexPath:indexPath];
    }else{
        return [self autoCompletionCellForRowAtIndexPath:indexPath];
    }
}

- (MessageTableViewCell *)messageCellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    MessageTableViewCell *cell = (MessageTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:MessengerCellIdentifier];
    cell.delegate = self;
    Message *message = self.messageObjects[indexPath.row];
    NSDate *timeAgo = message[@"date"];

    if(self.UsersAndImages[message[@"username"]]){
        cell.thumbnailView.image = [UIImage imageWithData:self.UsersAndImages[message[@"username"]]];
    }else{
        cell.thumbnailView.image = [UIImage systemImageNamed:@"person"];
    }
    cell.bodyLabel.text = message[@"text"];
    cell.titleLabel.text = [NSString stringWithFormat:@"%@   -   %@",message[@"username"], timeAgo.shortTimeAgoSinceNow];
    cell.indexPath = indexPath;
    cell.usedForMessage = YES;
    cell.transform = self.tableView.transform;
    cell.message = message;
    
    return cell;

}



- (MessageTableViewCell *)autoCompletionCellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    MessageTableViewCell *cell = (MessageTableViewCell *)[self.autoCompletionView dequeueReusableCellWithIdentifier:AutoCompletionCellIdentifier];
    cell.indexPath = indexPath;
    NSString *text = self.searchResult[indexPath.row];
    
    if([self.foundPrefix isEqualToString:@"#"]){
        text = [NSString stringWithFormat:@"# %@", text];
    }else if (([self.foundPrefix isEqualToString:@":"] || [self.foundPrefix isEqualToString:@"+:"])) {
        text = [NSString stringWithFormat:@":%@:", text];
    }
    
    cell.titleLabel.text = text;
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    MessageTableViewCell *cell = (MessageTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:MessengerCellIdentifier];
    if([tableView isEqual:self.tableView]){
        
        Message *message = self.messageObjects[indexPath.row];
        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        paragraphStyle.alignment = NSTextAlignmentLeft;
        CGFloat pointSize = [MessageTableViewCell defaultFontSize];
        NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:pointSize], NSParagraphStyleAttributeName: paragraphStyle};
        
        CGFloat width = CGRectGetWidth(tableView.frame)-kMessageTableViewCellAvatarHeight;
        width -= 25.0;
        
        CGRect titleBounds = [message.username boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:NULL];
        CGRect bodyBounds = [message.text boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:NULL];

        if(message.text.length == 0){
            return 0.0;
        }

        CGFloat height = CGRectGetHeight(titleBounds);
        height += CGRectGetHeight(bodyBounds);
        height += 40.0;

        if (height < kMessageTableViewCellMinimumHeight){
            height = kMessageTableViewCellMinimumHeight;
        }

        return height;
    }else{
        return kMessageTableViewCellMinimumHeight;
    }
}


#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if([tableView isEqual:self.autoCompletionView]){
        
        NSMutableString *item = [self.searchResult[indexPath.row] mutableCopy];
        if([self.foundPrefix isEqualToString:@"@"] && self.foundPrefixRange.location == 0){
            [item appendString:@":"];
        }else if(([self.foundPrefix isEqualToString:@":"] || [self.foundPrefix isEqualToString:@"+:"])){
            [item appendString:@":"];
        }
        [item appendString:@" "];
        [self acceptAutoCompletionWithString:item keepPrefix:YES];
    }
}


#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [super scrollViewDidScroll:scrollView];
}



#pragma mark - Lifeterm

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Navigation


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([[segue identifier] isEqualToString:@"showMembersSegue"]){
        MembersListViewController *membersListViewController = [segue destinationViewController];
        membersListViewController.group = self.group;
        membersListViewController.UserToImage = self.UsersAndImages;
        membersListViewController.UserAndUserObjects = self.UsersAndUserObjects;
        return;
    }
    if([[segue identifier] isEqualToString:@"chatToProfile"]){
        Message *clickedMessage = sender;
        UINavigationController *navController = [segue destinationViewController];
        ProfileViewController *profileViewController = (ProfileViewController *)([navController viewControllers][0]);
        profileViewController.message = clickedMessage;
        profileViewController.user = self.UsersAndUserObjects[clickedMessage.username];
        profileViewController.UsersAndImages = self.UsersAndImages;
        profileViewController.hideCameraButton = YES;
        profileViewController.UserAndUserObjects = self.UsersAndUserObjects;
        return;
    }
}
@end
