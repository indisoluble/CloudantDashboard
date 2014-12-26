//
//  ICDDatabasesTableViewController.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 23/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import "ICDDatabasesTableViewController.h"

#import "ICDDocumentsTableViewController.h"

#import "ICDAuthorizationFactory.h"
#import "ICDNetworkManager+Helper.h"

#import "ICDRequestAllDatabases.h"
#import "ICDRequestCreateDatabase.h"
#import "ICDRequestDeleteDatabase.h"

#import "ICDModelDatabase.h"

#import "ICDLog.h"



typedef void (^ICDDatabasesTVCAlertViewBlockType)(void);



NSString * const kICDDatabasesTVCCellID = @"databaseCell";



@interface ICDDatabasesTVCAlertView : UIAlertView

@property (copy, nonatomic) ICDDatabasesTVCAlertViewBlockType block;

@end



@interface ICDDatabasesTableViewController ()
    <UIAlertViewDelegate,
    ICDRequestAllDatabasesDelegate,
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

@property (strong, nonatomic) ICDDatabasesTVCAlertView *askAuthDataAlertView;
@property (strong, nonatomic) UIAlertView *askDatabaseNameAlertView;

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
        [authentication resolveUsername:&username password:&password error:nil];
        
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
    
    [self customizeUI];
    
    [self authorizeUserBeforeExecutingRequestAllDBs];
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


#pragma mark - UIAlertViewDelegate methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    
    if ([alertView isKindOfClass:[ICDDatabasesTVCAlertView class]])
    {
        if ([buttonTitle isEqualToString:NSLocalizedString(@"Continue", @"Continue")])
        {
            ICDDatabasesTVCAlertView *blockAlertView = (ICDDatabasesTVCAlertView *)alertView;
            
            UITextField *usernameTextField = [blockAlertView textFieldAtIndex:0];
            UITextField *passwordTextField = [blockAlertView textFieldAtIndex:1];
            
            NSError *thisError = nil;
            id<ICDAuthorizationProtocol> authentication = [ICDAuthorizationFactory authorization];
            if ([authentication saveUsername:usernameTextField.text password:passwordTextField.text error:&thisError])
            {
                blockAlertView.block();
            }
            else
            {
                [self showAlertViewWithTitle:NSLocalizedString(@"Error", @"Error") message:thisError.localizedDescription];
            }
        }
    }
    else if ([buttonTitle isEqualToString:NSLocalizedString(@"Create", @"Create")])
    {
        UITextField *textField = [alertView textFieldAtIndex:0];
        
        [self authorizeUserBeforeExecutingRequestCreateDBWithName:textField.text];
    }
    
    [self releaseAskAuthorizationDataAlertView];
    [self releaseAskDatabaseNameAlertView];
}


#pragma mark - ICDRequestAllDatabasesDelegate methods
- (void)requestAllDatabases:(id<ICDRequestProtocol>)request didGetDatabases:(NSArray *)databases
{
    [self releaseRequestAllDBs];
    
    self.allDatabases = [NSMutableArray arrayWithArray:databases];
    
    [self.refreshControl endRefreshing];
    [self.tableView reloadData];
}

- (void)requestAllDatabases:(id<ICDRequestProtocol>)request didFailWithError:(NSError *)error
{
    ICDLogError(@"Error: %@", error);
    
    [self releaseRequestAllDBs];
    
    [self.refreshControl endRefreshing];
}


#pragma mark - ICDRequestCreateDatabaseDelegate methods
- (void)requestCreateDatabase:(id<ICDRequestProtocol>)request didCreateDatabaseWithName:(NSString *)dbName
{
    [self releaseRequestCreateDB];
    
    ICDModelDatabase *database = [ICDModelDatabase databaseWithName:dbName];
    [self.allDatabases addObject:database];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:([self.allDatabases count] - 1) inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)requestCreateDatabase:(id<ICDRequestProtocol>)request didFailWithError:(NSError *)error
{
    ICDLogError(@"Error: %@", error);
    
    [self releaseRequestCreateDB];
}


#pragma mark - ICDRequestDeleteDatabaseDelegate methods
- (void)requestDeleteDatabase:(id<ICDRequestProtocol>)request didDeleteDatabaseWithName:(NSString *)dbName
{
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
    ICDLogError(@"Error: %@", error);
    
    [self releaseRequestDeleteDB];
}


#pragma mark - Private methods
- (void)customizeUI
{
    [self addAddBarButtonItem];
    [self addRefreshControl];
}

- (void)addAddBarButtonItem
{
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                          target:self
                                                                          action:@selector(askNameBeforeCreatingDatabase)];
    self.navigationItem.rightBarButtonItem = item;
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
    if (![self authorizeUserBeforeExecutingRequestAllDBs])
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

- (void)askAuthorizationDataBeforeExecutingBlock:(ICDDatabasesTVCAlertViewBlockType)block
{
    self.askAuthDataAlertView = [[ICDDatabasesTVCAlertView alloc] initWithTitle:NSLocalizedString(@"Cloudant Login", @"Cloudant Login")
                                                                        message:NSLocalizedString(@"Type username and password", @"Type username and password")
                                                                       delegate:self
                                                              cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                              otherButtonTitles:NSLocalizedString(@"Continue", @"Continue"), nil];
    self.askAuthDataAlertView.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    self.askAuthDataAlertView.block = block;
    
    [self.askAuthDataAlertView show];
}

- (void)releaseAskAuthorizationDataAlertView
{
    if (self.askAuthDataAlertView)
    {
        self.askAuthDataAlertView.delegate = nil;
        self.askAuthDataAlertView = nil;
    }
}

- (void)askNameBeforeCreatingDatabase
{
    self.askDatabaseNameAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Add New Database", @"Add New Database")
                                                               message:NSLocalizedString(@"Name of database", @"Name of database")
                                                              delegate:self
                                                     cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                     otherButtonTitles:NSLocalizedString(@"Create", @"Create"), nil];
    self.askDatabaseNameAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    [self.askDatabaseNameAlertView show];
}

- (void)releaseAskDatabaseNameAlertView
{
    if (self.askDatabaseNameAlertView)
    {
        self.askDatabaseNameAlertView.delegate = nil;
        self.askDatabaseNameAlertView = nil;
    }
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

- (BOOL)authorizeUserBeforeExecutingRequestAllDBs
{
    if (self.networkManager)
    {
        return [self executeRequestAllDBs];
    }
    
    __weak ICDDatabasesTableViewController *weakSelf = self;
    [self askAuthorizationDataBeforeExecutingBlock:^{
        __strong ICDDatabasesTableViewController *strongSelf = weakSelf;
        if (strongSelf)
        {
            [strongSelf executeRequestAllDBs];
        }
    }];
    
    return NO;
}

- (BOOL)executeRequestAllDBs
{
    if ([self isExecutingRequest])
    {
        ICDLogTrace(@"There is a request ongoing. Abort");
        
        return NO;
    }
    
    [self.refreshControl beginRefreshing];
    
    self.requestAllDBs = [[ICDRequestAllDatabases alloc] init];
    self.requestAllDBs.delegate = self;
    
    [self.networkManager executeRequest:self.requestAllDBs];
    
    return YES;
}

- (void)releaseRequestAllDBs
{
    if (self.requestAllDBs)
    {
        self.requestAllDBs.delegate = nil;
        self.requestAllDBs = nil;
    }
}

- (BOOL)authorizeUserBeforeExecutingRequestCreateDBWithName:(NSString *)dbName
{
    if (self.networkManager)
    {
        return [self executeRequestCreateDBWithName:dbName];
    }
    
    __weak ICDDatabasesTableViewController *weakSelf = self;
    [self askAuthorizationDataBeforeExecutingBlock:^{
        __strong ICDDatabasesTableViewController *strongSelf = weakSelf;
        if (strongSelf)
        {
            [strongSelf executeRequestCreateDBWithName:dbName];
        }
    }];
    
    return NO;
}

- (BOOL)executeRequestCreateDBWithName:(NSString *)dbName
{
    if ([self isExecutingRequest])
    {
        ICDLogTrace(@"There is a request ongoing. Abort");
        
        return NO;
    }
    
    self.requestCreateDB = [[ICDRequestCreateDatabase alloc] initWithDatabaseName:dbName];
    if (!self.requestCreateDB)
    {
        ICDLogWarning(@"Request not created with database name <%@>. Abort", dbName);
        
        return NO;
    }
    
    self.requestCreateDB.delegate = self;
    
    [self.networkManager executeRequest:self.requestCreateDB];
    
    return YES;
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
    if ([self isExecutingRequest])
    {
        ICDLogTrace(@"There is a request ongoing. Abort");
        
        return NO;
    }
    
    self.requestDeleteDB = [[ICDRequestDeleteDatabase alloc] initWithDatabaseName:dbName];
    if (!self.requestDeleteDB)
    {
        ICDLogWarning(@"Request not created with database name <%@>. Abort", dbName);
        
        return NO;
    }
    
    self.requestDeleteDB.delegate = self;
    
    [self.networkManager executeRequest:self.requestDeleteDB];
    
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

- (BOOL)isExecutingRequest
{
    return (self.requestAllDBs || self.requestCreateDB || self.requestDeleteDB);
}

@end



@implementation ICDDatabasesTVCAlertView

@end
