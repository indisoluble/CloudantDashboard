//
//  ICDControllerDesignDocsData.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 17/01/2015.
//  Copyright (c) 2015 Enrique de la Torre. All rights reserved.
//

#import "ICDControllerDesignDocsData.h"

#import "ICDNetworkManagerFactory.h"

#import "ICDRequestAllDocuments.h"

#import "ICDLog.h"



@interface ICDControllerDesignDocsData () <ICDRequestAllDocumentsDelegate>

@property (assign, nonatomic) BOOL isRefreshingDesignDocs;

@property (strong, nonatomic) NSArray *allDesignDocs;

@end



@implementation ICDControllerDesignDocsData

#pragma mark - Init object
- (id)init
{
    return [self initWithDatabaseName:nil networkManager:nil];
}

- (id)initWithDatabaseName:(NSString *)databaseNameOrNil
            networkManager:(id<ICDNetworkManagerProtocol>)networkManagerOrNil
{
    self = [super init];
    if (self)
    {
        _databaseNameOrNil = databaseNameOrNil;
        _networkManager = (networkManagerOrNil ? networkManagerOrNil : [ICDNetworkManagerFactory networkManager]);
        
        _isRefreshingDesignDocs = NO;
        
        _allDesignDocs = @[];
    }
    
    return self;
}


#pragma mark - ICDRequestAllDocumentsForADatabaseDelegate methods
- (void)requestAllDocuments:(id<ICDRequestProtocol>)request didGetDocuments:(NSArray *)documents
{
    self.isRefreshingDesignDocs = NO;
    
    // Update data
    self.allDesignDocs = documents;
    
    // Notify
    if (self.delegate)
    {
        [self.delegate icdControllerDesignDocsData:self didRefreshDesignDocsWithResult:YES];
    }
}

- (void)requestAllDocuments:(id<ICDRequestProtocol>)request didFailWithError:(NSError *)error
{
    ICDLogError(@"Error: %@", error);
    
    self.isRefreshingDesignDocs = NO;
    
    // Notify
    if (self.delegate)
    {
        [self.delegate icdControllerDesignDocsData:self didRefreshDesignDocsWithResult:NO];
    }
}


#pragma mark - Public methods
- (NSInteger)numberOfDesignDocs
{
    return [self.allDesignDocs count];
}

- (ICDModelDocument *)designDocAtIndex:(NSUInteger)index
{
    return (ICDModelDocument *)self.allDesignDocs[index];
}

- (BOOL)asyncRefreshDesignDocs
{
    self.isRefreshingDesignDocs = [self executeRequestAllDesignDocs];
    if (self.isRefreshingDesignDocs && self.delegate)
    {
        [self.delegate icdControllerDesignDocsDataWillRefreshDesignDocs:self];
    }
    
    return self.isRefreshingDesignDocs;
}


#pragma mark - Private methods
- (BOOL)executeRequestAllDesignDocs
{
    ICDRequestAllDocumentsArguments *arguments = [ICDRequestAllDocumentsArguments allDesignDocs];
    ICDRequestAllDocuments *requestAllDocs = [[ICDRequestAllDocuments alloc] initWithDatabaseName:self.databaseNameOrNil
                                                                                        arguments:arguments];
    if (!requestAllDocs)
    {
        ICDLogWarning(@"Request not created with database name <%@>. Abort", self.databaseNameOrNil);
        
        return NO;
    }
    
    requestAllDocs.delegate = self;
    
    return [self.networkManager asyncExecuteRequest:requestAllDocs];
}

@end
