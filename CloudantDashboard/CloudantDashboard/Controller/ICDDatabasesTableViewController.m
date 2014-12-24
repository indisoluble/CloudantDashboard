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

#import "ICDModelDatabase.h"

#import "ICDLog.h"



NSString * const kICDDatabasesTVCCellID = @"databaseCell";



@interface ICDDatabasesTableViewController () <ICDRequestAllDatabasesDelegate>
{
    ICDNetworkManager *_networkManager;
    ICDRequestAllDatabases *_requestAllDBs;
}

@property (strong, nonatomic, readonly) ICDNetworkManager *networkManager;
@property (strong, nonatomic, readonly) ICDRequestAllDatabases *requestAllDBs;

@property (strong, nonatomic) NSArray *allDatabases;

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

- (ICDRequestAllDatabases *)requestAllDBs
{
    if (!_requestAllDBs)
    {
        _requestAllDBs = [[ICDRequestAllDatabases alloc] init];
        _requestAllDBs.delegate = self;
    }
    
    return _requestAllDBs;
}


#pragma mark - Init object
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        _allDatabases = @[];
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


#pragma mark - ICDRequestAllDatabasesDelegate methods
- (void)requestAllDatabases:(id<ICDRequestProtocol>)request didGetDatabases:(NSArray *)databases
{
    self.allDatabases = databases;
    
    [self.tableView reloadData];
}

- (void)requestAllDatabases:(id<ICDRequestProtocol>)request didFailWithError:(NSError *)error
{
    ICDLogError(@"Error: %@", error);
}


#pragma mark - Private methods
- (void)executeRequestAllDBs
{
    if (self.networkManager)
    {
        [self.networkManager executeRequest:self.requestAllDBs];
    }
}

- (void)prepareForSegueDocumentsVC:(ICDDocumentsTableViewController *)documentVC
                          withCell:(UITableViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    ICDModelDatabase *database = (ICDModelDatabase *)self.allDatabases[indexPath.row];
    
    [documentVC useNetworkManager:self.networkManager databaseName:database.name];
}

@end
