//
//  ICDDatabasesTableViewController.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 23/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import <UIAlertView-Blocks/UIAlertView+Blocks.h>

#import "ICDDatabasesTableViewController.h"

#import "ICDDocumentsTableViewController.h"

#import "ICDAuthorizationFactory.h"
#import "ICDNetworkManager+Helper.h"

#import "ICDRequestAllDatabases.h"
#import "ICDRequestCreateDatabase.h"
#import "ICDRequestDeleteDatabase.h"

#import "ICDModelDatabase.h"

#import "ICDLog.h"
#import "ICDCommonAnimationDuration.h"



NSString * const kICDDatabasesTVCCellID = @"databaseCell";



@interface ICDDatabasesTableViewController ()
    <ICDRequestAllDatabasesDelegate,
    ICDRequestCreateDatabaseDelegate,
    ICDRequestDeleteDatabaseDelegate>
{
    ICDNetworkManager *_networkManager;
}

@property (strong, nonatomic, readonly) ICDNetworkManager *networkManager;

@property (strong, nonatomic) ICDRequestAllDatabases *requestAllDBs;
@property (strong, nonatomic) ICDRequestCreateDatabase *requestCreateDB;
@property (strong, nonatomic) ICDRequestDeleteDatabase *requestDeleteDB;

@property (strong, nonatomic) NSMutableArray *allDatabases;

@property (assign, nonatomic) BOOL isViewVisible;

@end



@implementation ICDDatabasesTableViewController

#pragma mark - Synthesize properties
- (ICDNetworkManager *)networkManager
{
    if (!_networkManager)
    {
        id<ICDAuthorizationProtocol> authentication = [ICDAuthorizationFactory authorization];
        
        NSString *username = nil;
        NSString *password = nil;
        [authentication retrieveUsername:&username password:&password error:nil];
        
        _networkManager = [ICDNetworkManager networkManagerWithUsername:username password:password];
    }
    
    return _networkManager;
}


#pragma mark - Init object
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        _allDatabases = [NSMutableArray array];
        
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
    
    [self checkAuthorizationBeforeExecutingRequestAllDBs];
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
        [segue.destinationViewController isKindOfClass:[ICDDocumentsTableViewController class]])
    {
        [self prepareForSegueDocumentsVC:segue.destinationViewController withCell:sender];
    }
}


#pragma mark - UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.allDatabases count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ICDModelDatabase *database = (ICDModelDatabase *)self.allDatabases[indexPath.row];
    
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
    ICDModelDatabase *database = (ICDModelDatabase *)self.allDatabases[indexPath.row];
    
    [self executeRequestDeleteDBWithName:database.name];
}


#pragma mark - ICDRequestAllDatabasesDelegate methods
- (void)requestAllDatabases:(id<ICDRequestProtocol>)request didGetDatabases:(NSArray *)databases
{
    if (request != self.requestAllDBs)
    {
        ICDLogDebug(@"Received databases from unexpected request. Ignore");
        
        return;
    }
    
    [self releaseRequestAllDBs];
    
    self.allDatabases = [NSMutableArray arrayWithArray:databases];
    [self.allDatabases sortUsingSelector:@selector(compare:)];
    
    [self.tableView reloadData];
    
    [self.refreshControl endRefreshing];
}

- (void)requestAllDatabases:(id<ICDRequestProtocol>)request didFailWithError:(NSError *)error
{
    if (request != self.requestAllDBs)
    {
        ICDLogDebug(@"Received error from unexpected request. Ignore");
        
        return;
    }
    
    ICDLogError(@"Error: %@", error);
    
    [self releaseRequestAllDBs];
    
    [self.refreshControl endRefreshing];
}


#pragma mark - ICDRequestCreateDatabaseDelegate methods
- (void)requestCreateDatabase:(id<ICDRequestProtocol>)request didCreateDatabaseWithName:(NSString *)dbName
{
    if (request != self.requestCreateDB)
    {
        ICDLogDebug(@"Received database from unexpected request. Ignore");
        
        return;
    }
    
    [self releaseRequestCreateDB];
    
    ICDModelDatabase *database = [ICDModelDatabase databaseWithName:dbName];
    NSUInteger index = [self.allDatabases indexOfObject:database
                                          inSortedRange:NSMakeRange(0, [self.allDatabases count])
                                                options:NSBinarySearchingInsertionIndex
                                        usingComparator:^NSComparisonResult(id obj1, id obj2) {
                                            return [(ICDModelDatabase *)obj1 compare:(ICDModelDatabase *)obj2];
                                        }];
    [self.allDatabases insertObject:database atIndex:index];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
    if (self.isViewVisible)
    {
        [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
    }
}

- (void)requestCreateDatabase:(id<ICDRequestProtocol>)request didFailWithError:(NSError *)error
{
    if (request != self.requestCreateDB)
    {
        ICDLogDebug(@"Received error from unexpected request. Ignore");
        
        return;
    }
    
    ICDLogError(@"Error: %@", error);
    
    [self releaseRequestCreateDB];
}


#pragma mark - ICDRequestDeleteDatabaseDelegate methods
- (void)requestDeleteDatabase:(id<ICDRequestProtocol>)request didDeleteDatabaseWithName:(NSString *)dbName
{
    if (request != self.requestDeleteDB)
    {
        ICDLogDebug(@"Received database from unexpected request. Ignore");
        
        return;
    }
    
    [self releaseRequestDeleteDB];
    
    ICDModelDatabase *database = [ICDModelDatabase databaseWithName:dbName];
    NSUInteger index = [self.allDatabases indexOfObject:database];
    if (index == NSNotFound)
    {
        ICDLogError(@"Database <%@> is not in the list. Abort", dbName);
        
        return;
    }
    
    [self.allDatabases removeObjectAtIndex:index];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)requestDeleteDatabase:(id<ICDRequestProtocol>)request didFailWithError:(NSError *)error
{
    if (request != self.requestDeleteDB)
    {
        ICDLogDebug(@"Received error from unexpected request. Ignore");
        
        return;
    }
    
    ICDLogError(@"Error: %@", error);
    
    [self releaseRequestDeleteDB];
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
    if (self.networkManager)
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
                                                            action:@selector(authorizeUserBeforeExecutingRequestAllDBs)];
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

- (void)refreshDatabaseListAfterPullingToRefresh
{
    BOOL endRefreshingAnimation = YES;
    
    if (self.networkManager)
    {
        endRefreshingAnimation = ![self executeRequestAllDBs];
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

- (void)prepareForSegueDocumentsVC:(ICDDocumentsTableViewController *)documentVC
                          withCell:(UITableViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    ICDModelDatabase *database = (ICDModelDatabase *)self.allDatabases[indexPath.row];
    
    [documentVC useNetworkManager:self.networkManager databaseName:database.name];
}

- (void)authorizeUserBeforeExecutingRequestAllDBs
{
    __block UIAlertView *alertView = nil;
    __weak ICDDatabasesTableViewController *weakSelf = self;
    
    void (^continueAction)(void) = ^(void)
    {
        __strong ICDDatabasesTableViewController *strongSelf = weakSelf;
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
            [strongSelf addLoginLogoutBarButtonItem];
            
            [strongSelf executeRequestAllDBs];
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
    __weak ICDDatabasesTableViewController *weakSelf = self;
    
    void (^createAction)(void) = ^(void)
    {
        __strong ICDDatabasesTableViewController *strongSelf = weakSelf;
        if (strongSelf)
        {
            UITextField *textField = [alertView textFieldAtIndex:0];
            
            [strongSelf executeRequestCreateDBWithName:textField.text];
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
    
    [self releaseNetworkManager];
    
    [self releaseRequestAllDBs];
    [self releaseRequestCreateDB];
    [self releaseRequestDeleteDB];
    
    self.allDatabases = [NSMutableArray array];
    
    [self addLoginLogoutBarButtonItem];
    
    [self.tableView reloadData];
    
    [self.refreshControl endRefreshing];
}

- (void)releaseNetworkManager
{
    if (_networkManager)
    {
        _networkManager = nil;
    }
}

- (BOOL)checkAuthorizationBeforeExecutingRequestAllDBs
{
    BOOL result = NO;
    
    if (self.networkManager)
    {
        result = [self executeRequestAllDBs];
    }
    else
    {
        [self authorizeUserBeforeExecutingRequestAllDBs];
    }
    
    return result;
}

- (BOOL)executeRequestAllDBs
{
    if (self.requestAllDBs)
    {
        ICDLogTrace(@"Already executing this request");
        
        return NO;
    }
    
    self.requestAllDBs = [[ICDRequestAllDatabases alloc] init];
    self.requestAllDBs.delegate = self;
    
    BOOL success = [self.networkManager asyncExecuteRequest:self.requestAllDBs];
    if (success)
    {
        [self.refreshControl beginRefreshing];
    }
    else
    {
        [self releaseRequestAllDBs];
    }
    
    return success;
}

- (void)releaseRequestAllDBs
{
    if (self.requestAllDBs)
    {
        self.requestAllDBs.delegate = nil;
        self.requestAllDBs = nil;
    }
}

- (void)checkAuthorizationBeforeAskingDatabaseName
{
    if (self.networkManager)
    {
        [self askNameBeforeCreatingDatabase];
    }
    else
    {
        [self showLoginRequiredAlertView];
    }
}

- (BOOL)executeRequestCreateDBWithName:(NSString *)dbName
{
    if (self.requestCreateDB)
    {
        ICDLogTrace(@"Already executing this request");
        
        return NO;
    }
    
    self.requestCreateDB = [[ICDRequestCreateDatabase alloc] initWithDatabaseName:dbName];
    if (!self.requestCreateDB)
    {
        ICDLogWarning(@"Request not created with database name <%@>. Abort", dbName);
        
        return NO;
    }
    
    self.requestCreateDB.delegate = self;
    
    BOOL success = [self.networkManager asyncExecuteRequest:self.requestCreateDB];
    if (!success)
    {
        [self releaseRequestCreateDB];
    }
    
    return success;
}

- (void)releaseRequestCreateDB
{
    if (self.requestCreateDB)
    {
        self.requestCreateDB.delegate = nil;
        self.requestCreateDB = nil;
    }
}

- (BOOL)executeRequestDeleteDBWithName:(NSString *)dbName
{
    if (self.requestDeleteDB)
    {
        ICDLogTrace(@"Already executing this request");
        
        return NO;
    }
    
    self.requestDeleteDB = [[ICDRequestDeleteDatabase alloc] initWithDatabaseName:dbName];
    if (!self.requestDeleteDB)
    {
        ICDLogWarning(@"Request not created with database name <%@>. Abort", dbName);
        
        return NO;
    }
    
    self.requestDeleteDB.delegate = self;
    
    BOOL success = [self.networkManager asyncExecuteRequest:self.requestDeleteDB];
    if (!success)
    {
        [self releaseRequestDeleteDB];
    }
    
    return YES;
}

- (void)releaseRequestDeleteDB
{
    if (self.requestDeleteDB)
    {
        self.requestDeleteDB.delegate = nil;
        self.requestDeleteDB = nil;
    }
}

@end
