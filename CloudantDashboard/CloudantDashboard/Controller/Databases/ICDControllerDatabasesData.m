//
//  ICDControllerDatabasesData.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 03/01/2015.
//  Copyright (c) 2015 Enrique de la Torre. All rights reserved.
//

#import "ICDControllerDatabasesData.h"

#import "ICDNetworkManagerFactory.h"

#import "ICDRequestAllDatabases.h"
#import "ICDRequestCreateDatabase.h"
#import "ICDRequestDeleteDatabase.h"

#import "ICDLog.h"



@interface ICDControllerDatabasesData ()
    <ICDRequestAllDatabasesDelegate,
    ICDRequestCreateDatabaseDelegate,
    ICDRequestDeleteDatabaseDelegate>

@property (strong, nonatomic) NSMutableArray *allDatabases;

@end



@implementation ICDControllerDatabasesData

#pragma mark - Init
- (id)init
{
    return [self initWithNetworkManager:nil];
}

- (id)initWithUsername:(NSString *)usernameOrNil password:(NSString *)passwordOrNil
{
    id<ICDNetworkManagerProtocol> networkManager = [ICDNetworkManagerFactory networkManagerWithUsername:usernameOrNil
                                                                                               password:passwordOrNil];
    
    return [self initWithNetworkManager:networkManager];
}

- (id)initWithNetworkManager:(id<ICDNetworkManagerProtocol>)networkManagerOrNil
{
    self = [super init];
    if (self)
    {
        _networkManager = (networkManagerOrNil ? networkManagerOrNil : [ICDNetworkManagerFactory networkManager]);
        
        _allDatabases = [NSMutableArray array];
    }
    
    return self;
}


#pragma mark - ICDRequestAllDatabasesDelegate methods
- (void)requestAllDatabases:(id<ICDRequestProtocol>)request didGetDatabases:(NSArray *)databases
{
    // Update data
    self.allDatabases = [NSMutableArray arrayWithArray:databases];
    [self.allDatabases sortUsingSelector:@selector(compare:)];
    
    // Notify
    if (self.delegate)
    {
        [self.delegate icdControllerDatabasesData:self didRefreshDBsWithResult:YES];
    }
}

- (void)requestAllDatabases:(id<ICDRequestProtocol>)request didFailWithError:(NSError *)error
{
    ICDLogError(@"Error: %@", error);
    
    // Notify
    if (self.delegate)
    {
        [self.delegate icdControllerDatabasesData:self didRefreshDBsWithResult:NO];
    }
}


#pragma mark - ICDRequestCreateDatabaseDelegate methods
- (void)requestCreateDatabase:(id<ICDRequestProtocol>)request didCreateDatabaseWithName:(NSString *)dbName
{
    // Update data
    ICDModelDatabase *database = [ICDModelDatabase databaseWithName:dbName];
    NSUInteger index = [self.allDatabases indexOfObject:database
                                          inSortedRange:NSMakeRange(0, [self.allDatabases count])
                                                options:NSBinarySearchingInsertionIndex
                                        usingComparator:^NSComparisonResult(id obj1, id obj2) {
                                            return [(ICDModelDatabase *)obj1 compare:(ICDModelDatabase *)obj2];
                                        }];
    [self.allDatabases insertObject:database atIndex:index];
    
    // Notify
    if (self.delegate)
    {
        [self.delegate icdControllerDatabasesData:self didCreateDBAtIndex:index];
    }
}

- (void)requestCreateDatabase:(id<ICDRequestProtocol>)request didFailWithError:(NSError *)error
{
    ICDLogError(@"Error: %@", error);
}


#pragma mark - ICDRequestDeleteDatabaseDelegate methods
- (void)requestDeleteDatabase:(id<ICDRequestProtocol>)request didDeleteDatabaseWithName:(NSString *)dbName
{
    // Update data
    ICDModelDatabase *database = [ICDModelDatabase databaseWithName:dbName];
    NSUInteger index = [self.allDatabases indexOfObject:database];
    if (index == NSNotFound)
    {
        ICDLogError(@"Database <%@> is not in the list. Abort", dbName);
        
        return;
    }
    
    [self.allDatabases removeObjectAtIndex:index];
    
    // Notify
    if (self.delegate)
    {
        [self.delegate icdControllerDatabasesData:self didDeleteDBAtIndex:index];
    }
}

- (void)requestDeleteDatabase:(id<ICDRequestProtocol>)request didFailWithError:(NSError *)error
{
    ICDLogError(@"Error: %@", error);
}


#pragma mark - Public methods
- (NSInteger)numberOfDatabases
{
    return [self.allDatabases count];
}

- (ICDModelDatabase *)databaseAtIndex:(NSUInteger)index
{
    return (ICDModelDatabase *)self.allDatabases[index];
}

- (BOOL)asyncRefreshDBs
{
    BOOL success = [self executeRequestAllDBs];
    if (success && self.delegate)
    {
        [self.delegate icdControllerDatabasesDataWillRefreshDBs:self];
    }
    
    return success;
}

- (BOOL)asyncCreateDBWithName:(NSString *)dbName
{
    return [self executeRequestCreateDBWithName:dbName];
}

- (BOOL)asyncDeleteDBAtIndex:(NSUInteger)index
{
    ICDModelDatabase *database = [self databaseAtIndex:index];
    
    return [self executeRequestDeleteDBWithName:database.name];
}


#pragma mark - Private methods
- (BOOL)executeRequestAllDBs
{
    ICDRequestAllDatabases *requestAllDBs = [[ICDRequestAllDatabases alloc] init];
    requestAllDBs.delegate = self;
    
    return [self.networkManager asyncExecuteRequest:requestAllDBs];
}

- (BOOL)executeRequestCreateDBWithName:(NSString *)dbName
{
    ICDRequestCreateDatabase *requestCreateDB = [[ICDRequestCreateDatabase alloc] initWithDatabaseName:dbName];
    if (!requestCreateDB)
    {
        ICDLogWarning(@"Request not created with database name <%@>. Abort", dbName);
        
        return NO;
    }
    
    requestCreateDB.delegate = self;
    
    return [self.networkManager asyncExecuteRequest:requestCreateDB];
}

- (BOOL)executeRequestDeleteDBWithName:(NSString *)dbName
{
    ICDRequestDeleteDatabase *requestDeleteDB = [[ICDRequestDeleteDatabase alloc] initWithDatabaseName:dbName];
    if (!requestDeleteDB)
    {
        ICDLogWarning(@"Request not created with database name <%@>. Abort", dbName);
        
        return NO;
    }
    
    requestDeleteDB.delegate = self;
    
    return [self.networkManager asyncExecuteRequest:requestDeleteDB];
}

@end
