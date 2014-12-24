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
#import "ICDRequestDeleteDatabase.h"

#import "ICDModelDatabase.h"

#import "ICDLog.h"



NSString * const kICDDatabasesTVCCellID = @"databaseCell";



@interface ICDDatabasesTableViewController () <ICDRequestAllDatabasesDelegate, ICDRequestDeleteDatabaseDelegate>
{
    ICDNetworkManager *_networkManager;
}

@property (strong, nonatomic, readonly) ICDNetworkManager *networkManager;

@property (strong, nonatomic) ICDRequestAllDatabases *requestAllDBs;
@property (strong, nonatomic) ICDRequestDeleteDatabase *requestDeleteDB;

@property (strong, nonatomic) NSMutableArray *allDatabases;

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
    
    [self addRefreshControl];
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

#pragma mark - ICDRequestDeleteDatabaseDelegate methods
- (void)requestDeleteDatabase:(id<ICDRequestProtocol>)request didDeleteDatabaseWithName:(NSString *)dbName
{
    [self releaseRequestDeleteDB];
    
    ICDModelDatabase *database = [ICDModelDatabase databaseWithName:dbName];
    [self.allDatabases removeObject:database];
    
    [self.tableView reloadData];
}

- (void)requestDeleteDatabase:(id<ICDRequestProtocol>)request didFailWithError:(NSError *)error
{
    ICDLogError(@"Error: %@", error);
    
    [self releaseRequestDeleteDB];
}


#pragma mark - Private methods
- (void)addRefreshControl
{
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(executeRequestAllDBs) forControlEvents:UIControlEventValueChanged];
    
    self.refreshControl = refreshControl;
}

- (void)executeRequestAllDBs
{
    if ([self isExecutingRequest])
    {
        ICDLogTrace(@"There is a request ongoing. Abort");
        
        return;
    }
    
    if (self.networkManager)
    {
        self.requestAllDBs = [[ICDRequestAllDatabases alloc] init];
        self.requestAllDBs.delegate = self;
        
        [self.networkManager executeRequest:self.requestAllDBs];
    }
}

- (void)releaseRequestAllDBs
{
    if (self.requestAllDBs)
    {
        self.requestAllDBs.delegate = nil;
        self.requestAllDBs = nil;
    }
}

- (void)executeRequestDeleteDBWithName:(NSString *)dbName
{
    if ([self isExecutingRequest])
    {
        ICDLogTrace(@"There is a request ongoing. Abort");
        
        return;
    }
    
    if (self.networkManager && dbName)
    {
        self.requestDeleteDB = [[ICDRequestDeleteDatabase alloc] initWithDatabaseName:dbName];
        self.requestDeleteDB.delegate = self;
        
        [self.networkManager executeRequest:self.requestDeleteDB];
    }
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
    return (self.requestAllDBs || self.requestDeleteDB);
}

- (void)prepareForSegueDocumentsVC:(ICDDocumentsTableViewController *)documentVC
                          withCell:(UITableViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    ICDModelDatabase *database = (ICDModelDatabase *)self.allDatabases[indexPath.row];
    
    [documentVC useNetworkManager:self.networkManager databaseName:database.name];
}

@end
