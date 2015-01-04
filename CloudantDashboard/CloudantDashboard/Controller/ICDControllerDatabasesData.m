//
//  ICDControllerDatabasesData.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 03/01/2015.
//  Copyright (c) 2015 Enrique de la Torre. All rights reserved.
//

#import "ICDControllerDatabasesData.h"

#import "ICDAuthorizationFactory.h"
#import "ICDNetworkManagerFactory.h"

#import "ICDRequestAllDatabases.h"
#import "ICDRequestCreateDatabase.h"
#import "ICDRequestDeleteDatabase.h"

#import "ICDLog.h"



@interface ICDControllerDatabasesData ()
    <ICDRequestAllDatabasesDelegate,
    ICDRequestCreateDatabaseDelegate,
    ICDRequestDeleteDatabaseDelegate>
{
    id<ICDNetworkManagerProtocol> _networkManager;
}

@property (strong, nonatomic) NSMutableArray *ongoingRequests;

@property (strong, nonatomic) NSMutableArray *allDatabases;

@end



@implementation ICDControllerDatabasesData

#pragma mark - Synthesize properties
- (id<ICDNetworkManagerProtocol>)networkManager
{
    if (!_networkManager)
    {
        id<ICDAuthorizationProtocol> authentication = [ICDAuthorizationFactory authorization];
        
        NSString *username = nil;
        NSString *password = nil;
        [authentication retrieveUsername:&username password:&password error:nil];
        
        _networkManager = [ICDNetworkManagerFactory networkManagerWithUsername:username password:password];
    }
    
    return _networkManager;
}


#pragma mark - Init
- (id)init
{
    self = [super init];
    if (self)
    {
        _ongoingRequests = [NSMutableArray array];
        
        _allDatabases = [NSMutableArray array];
    }
    
    return self;
}


#pragma mark - ICDRequestAllDatabasesDelegate methods
- (void)requestAllDatabases:(id<ICDRequestProtocol>)request didGetDatabases:(NSArray *)databases
{
    [self.ongoingRequests removeObject:request];
    
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
    
    [self.ongoingRequests removeObject:request];
    
    // Notify
    if (self.delegate)
    {
        [self.delegate icdControllerDatabasesData:self didRefreshDBsWithResult:NO];
    }
}


#pragma mark - ICDRequestCreateDatabaseDelegate methods
- (void)requestCreateDatabase:(id<ICDRequestProtocol>)request didCreateDatabaseWithName:(NSString *)dbName
{
    [self.ongoingRequests removeObject:request];
    
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
    
    [self.ongoingRequests removeObject:request];
}


#pragma mark - ICDRequestDeleteDatabaseDelegate methods
- (void)requestDeleteDatabase:(id<ICDRequestProtocol>)request didDeleteDatabaseWithName:(NSString *)dbName
{
    [self.ongoingRequests removeObject:request];
    
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
    
    [self.ongoingRequests removeObject:request];
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

- (void)reset
{
    [self releaseNetworkManager];
    
    [self releaseOngoingRequests];
    
    self.allDatabases = [NSMutableArray array];
}


#pragma mark - Private methods
- (BOOL)executeRequestAllDBs
{
    ICDRequestAllDatabases *requestAllDBs = [[ICDRequestAllDatabases alloc] init];
    requestAllDBs.delegate = self;
    
    BOOL success = [self.networkManager asyncExecuteRequest:requestAllDBs];
    if (success)
    {
        [self.ongoingRequests addObject:requestAllDBs];
    }
    
    return success;
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
    
    BOOL success = [self.networkManager asyncExecuteRequest:requestCreateDB];
    if (success)
    {
        [self.ongoingRequests addObject:requestCreateDB];
    }
    
    return success;
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
    
    BOOL success = [self.networkManager asyncExecuteRequest:requestDeleteDB];
    if (success)
    {
        [self.ongoingRequests addObject:requestDeleteDB];
    }
    
    return YES;
}

- (void)releaseNetworkManager
{
    if (_networkManager)
    {
        _networkManager = nil;
    }
}

- (void)releaseOngoingRequests
{
    NSUInteger count = [self.ongoingRequests count];
    for (NSUInteger index = 0; index < count; index++)
    {
        id oneRequest = [self.ongoingRequests lastObject];
        if ([oneRequest respondsToSelector:@selector(setDelegate:)])
        {
            // Set delegate to nil, release the instance is not enought
            // The instance could send a message to the delegate before being freed from memory
            [oneRequest setDelegate:nil];
        }
        
        [self.ongoingRequests removeLastObject];
    }
}

@end
