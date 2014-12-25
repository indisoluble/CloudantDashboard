//
//  ICDDatabasesTableViewController.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 23/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import "ICDDatabasesTableViewController.h"

#import "ICDDocumentsTableViewController.h"

#import "ICDAuthorizationPlist.h"
#import "ICDNetworkManager+Helper.h"

#import "ICDRequestAllDatabases.h"
#import "ICDRequestCreateDatabase.h"
#import "ICDRequestDeleteDatabase.h"

#import "ICDModelDatabase.h"

#import "ICDLog.h"



NSString * const kICDDatabasesTVCCellID = @"databaseCell";



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

@property (strong, nonatomic) UIAlertView *askDatabaseNameAlertView;

@end



@implementation ICDDatabasesTableViewController

#pragma mark - Synthesize properties
- (ICDNetworkManager *)networkManager
{
    if (!_networkManager)
    {
        id<ICDAuthorizationProtocol> authentication = [[ICDAuthorizationPlist alloc] init];
        
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
    
    [self executeRequestAllDBs];
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
    if ([buttonTitle isEqualToString:NSLocalizedString(@"Create", @"Create")])
    {
        UITextField *textField = [alertView textFieldAtIndex:0];
        
        [self executeRequestCreateDBWithName:textField.text];
    }
    
    [self releaseAskDatbaseNameAlertView];
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
                       action:@selector(executeRequestAllDBsAfterPullingToRefresh)
             forControlEvents:UIControlEventValueChanged];
    
    self.refreshControl = refreshControl;
}

- (void)executeRequestAllDBsAfterPullingToRefresh
{
    if (![self executeRequestAllDBs])
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

- (void)releaseAskDatbaseNameAlertView
{
    if (self.askDatabaseNameAlertView)
    {
        self.askDatabaseNameAlertView.delegate = nil;
        self.askDatabaseNameAlertView = nil;
    }
}

- (BOOL)executeRequestAllDBs
{
    if ([self isExecutingRequest])
    {
        ICDLogTrace(@"There is a request ongoing. Abort");
        
        return NO;
    }
    
    if (!self.networkManager)
    {
        ICDLogTrace(@"No network manager. Abort");
        
        return NO;
    }
    
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

- (BOOL)executeRequestCreateDBWithName:(NSString *)dbName
{
    if ([self isExecutingRequest])
    {
        ICDLogTrace(@"There is a request ongoing. Abort");
        
        return NO;
    }
    
    if (!self.networkManager)
    {
        ICDLogTrace(@"No network manager. Abort");
        
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
    
    if (!self.networkManager)
    {
        ICDLogTrace(@"No network manager. Abort");
        
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
