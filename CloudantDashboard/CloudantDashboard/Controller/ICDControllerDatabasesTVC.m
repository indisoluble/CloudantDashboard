//
//  ICDControllerDatabasesTVC.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 23/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import <UIAlertView-Blocks/UIAlertView+Blocks.h>

#import "ICDControllerDatabasesTVC.h"

#import "ICDControllerDocumentsTVC.h"

#import "ICDControllerDatabasesData.h"

#import "ICDAuthorizationFactory.h"

#import "ICDLog.h"



NSString * const kICDDatabasesTVCCellID = @"databaseCell";



@interface ICDControllerDatabasesTVC () <ICDControllerDatabasesDataDelegate>
{
    ICDControllerDatabasesData *_data;
}

@property (strong, nonatomic, readonly) ICDControllerDatabasesData *data;

@property (assign, nonatomic) BOOL isViewVisible;

@end



@implementation ICDControllerDatabasesTVC

#pragma mark - Synthesize properties
- (ICDControllerDatabasesData *)data
{
    if (!_data)
    {
        _data = [[ICDControllerDatabasesData alloc] init];
        _data.delegate = self;
    }
    
    return _data;
}


#pragma mark - Init object
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        _isViewVisible = NO;
    }
    
    return self;
}


#pragma mark - Memory management
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}


#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.clearsSelectionOnViewWillAppear = NO;
    
    [self customizeUI];
    
    [self checkAuthorizationBeforeRefreshingDBs];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.isViewVisible = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.isViewVisible = NO;
}


#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]] &&
        [segue.destinationViewController isKindOfClass:[ICDControllerDocumentsTVC class]])
    {
        [self prepareForSegueDocumentsVC:segue.destinationViewController withCell:sender];
    }
}


#pragma mark - UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.data numberOfDatabases];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ICDModelDatabase *database = [self.data databaseAtIndex:indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kICDDatabasesTVCCellID forIndexPath:indexPath];
    cell.textLabel.text = database.name;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.data asyncDeleteDBAtIndex:indexPath.row];
}


#pragma mark - ICDControllerDatabasesDataDelegate methods
- (void)icdControllerDatabasesDataWillRefreshDBs:(ICDControllerDatabasesData *)data
{
    [self.refreshControl beginRefreshing];
}

- (void)icdControllerDatabasesData:(ICDControllerDatabasesData *)data
           didRefreshDBsWithResult:(BOOL)success
{
    if (success)
    {
        [self.tableView reloadData];
    }
    
    [self.refreshControl endRefreshing];
}

- (void)icdControllerDatabasesData:(ICDControllerDatabasesData *)data
                didCreateDBAtIndex:(NSUInteger)index
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
    if (self.isViewVisible)
    {
        [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
    }
}

- (void)icdControllerDatabasesData:(ICDControllerDatabasesData *)data
                didDeleteDBAtIndex:(NSUInteger)index
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}


#pragma mark - Private methods
- (void)customizeUI
{
    [self addAddBarButtonItem];
    [self addLoginLogoutBarButtonItem];
    
    [self addRefreshControl];
}

- (void)addAddBarButtonItem
{
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                          target:self
                                                                          action:@selector(checkAuthorizationBeforeAskingDatabaseName)];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)addLoginLogoutBarButtonItem
{
    if ([self.data.networkManager isAuthorized])
    {
        [self addLogoutBarButtonItem];
    }
    else
    {
        [self addLoginBarButtonItem];
    }
}

- (void)addLoginBarButtonItem
{
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Login", @"Login")
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(authorizeUserBeforeRefreshingDBs)];
    self.navigationItem.leftBarButtonItem = item;
}

- (void)addLogoutBarButtonItem
{
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Logout", @"Logout")
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(logoutUser)];
    self.navigationItem.leftBarButtonItem = item;
}

- (void)addRefreshControl
{
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self
                       action:@selector(refreshDatabaseListAfterPullingToRefresh)
             forControlEvents:UIControlEventValueChanged];
    
    self.refreshControl = refreshControl;
}

- (BOOL)checkAuthorizationBeforeRefreshingDBs
{
    BOOL result = NO;
    
    if ([self.data.networkManager isAuthorized])
    {
        result = [self.data asyncRefreshDBs];
    }
    else
    {
        [self authorizeUserBeforeRefreshingDBs];
    }
    
    return result;
}

- (void)refreshDatabaseListAfterPullingToRefresh
{
    BOOL endRefreshingAnimation = YES;
    
    if ([self.data.networkManager isAuthorized])
    {
        endRefreshingAnimation = ![self.data asyncRefreshDBs];
    }
    else
    {
        [self showLoginRequiredAlertView];
    }
    
    if (endRefreshingAnimation)
    {
        [self.refreshControl endRefreshing];
    }
}

- (void)checkAuthorizationBeforeAskingDatabaseName
{
    if ([self.data.networkManager isAuthorized])
    {
        [self askNameBeforeCreatingDatabase];
    }
    else
    {
        [self showLoginRequiredAlertView];
    }
}

- (void)authorizeUserBeforeRefreshingDBs
{
    __block UIAlertView *alertView = nil;
    __weak ICDControllerDatabasesTVC *weakSelf = self;
    
    void (^continueAction)(void) = ^(void)
    {
        __strong ICDControllerDatabasesTVC *strongSelf = weakSelf;
        if (!strongSelf)
        {
            return;
        }
        
        UITextField *usernameTextField = [alertView textFieldAtIndex:0];
        UITextField *passwordTextField = [alertView textFieldAtIndex:1];
        
        NSError *thisError = nil;
        id<ICDAuthorizationProtocol> authentication = [ICDAuthorizationFactory authorization];
        if ([authentication saveUsername:usernameTextField.text password:passwordTextField.text error:&thisError])
        {
            [strongSelf.data reset];
            
            [strongSelf addLoginLogoutBarButtonItem];
            
            [strongSelf.data asyncRefreshDBs];
        }
        else
        {
            [strongSelf showAlertViewWithTitle:NSLocalizedString(@"Error", @"Error") message:thisError.localizedDescription];
        }
    };
    
    RIButtonItem *continueItem = [RIButtonItem itemWithLabel:NSLocalizedString(@"Continue", @"Continue") action:continueAction];
    RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:NSLocalizedString(@"Cancel", @"Cancel")];
    
    alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Cloudant Login", @"Cloudant Login")
                                           message:NSLocalizedString(@"Type username and password", @"Type username and password")
                                  cancelButtonItem:cancelItem
                                  otherButtonItems:continueItem, nil];
    alertView.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    
    [alertView show];
}

- (void)askNameBeforeCreatingDatabase
{
    __block UIAlertView *alertView = nil;
    __weak ICDControllerDatabasesTVC *weakSelf = self;
    
    void (^createAction)(void) = ^(void)
    {
        __strong ICDControllerDatabasesTVC *strongSelf = weakSelf;
        if (strongSelf)
        {
            UITextField *textField = [alertView textFieldAtIndex:0];
            
            [strongSelf.data asyncCreateDBWithName:textField.text];
        }
    };
    
    RIButtonItem *createItem = [RIButtonItem itemWithLabel:NSLocalizedString(@"Create", @"Create") action:createAction];
    RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:NSLocalizedString(@"Cancel", @"Cancel")];
    
    alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Add New Database", @"Add New Database")
                                           message:NSLocalizedString(@"Name of database", @"Name of database")
                                  cancelButtonItem:cancelItem
                                  otherButtonItems:createItem, nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    [alertView show];
}

- (void)showLoginRequiredAlertView
{
    [self showAlertViewWithTitle:NSLocalizedString(@"Login required", @"Login required")
                         message:NSLocalizedString(@"You have to login first", @"You have to login first")];
}

- (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"Continue", @"Continue")
                                              otherButtonTitles:nil];
    [alertView show];
}

- (void)logoutUser
{
    id<ICDAuthorizationProtocol> authentication = [ICDAuthorizationFactory authorization];
    [authentication removeUsernamePasswordError:nil];
    
    [self.data reset];
    
    [self addLoginLogoutBarButtonItem];
    
    [self.tableView reloadData];
    
    [self.refreshControl endRefreshing];
}

- (void)prepareForSegueDocumentsVC:(ICDControllerDocumentsTVC *)documentVC
                          withCell:(UITableViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    ICDModelDatabase *database = [self.data databaseAtIndex:indexPath.row];
    
    [documentVC useNetworkManager:self.data.networkManager databaseName:database.name];
}

@end
