//
//  ICDControllerOneDatabaseData.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 18/01/2015.
//  Copyright (c) 2015 Enrique de la Torre. All rights reserved.
//

#import "ICDControllerOneDatabaseData.h"

#import "ICDModelDocument.h"

#import "ICDNetworkManagerFactory.h"

#import "ICDRequestAllDocuments.h"
#import "ICDRequestAllDocumentsArguments.h"

#import "ICDControllerOneDatabaseOptionAllDocs.h"
#import "ICDControllerOneDatabaseOptionAllDesignDocs.h"
#import "ICDControllerOneDatabaseOptionDesignDoc.h"

#import "ICDLog.h"



@interface ICDControllerOneDatabaseData () <ICDRequestAllDocumentsDelegate>

@property (strong, nonatomic, readonly) NSString *databaseNameOrNil;
@property (strong, nonatomic, readonly) id<ICDNetworkManagerProtocol> networkManager;

@property (strong, nonatomic, readonly) NSArray *options;

@property (assign, nonatomic) BOOL isRefreshingDesignDocs;

@end



@implementation ICDControllerOneDatabaseData

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
        
        _options = [ICDControllerOneDatabaseData basicOptionsWithDatabaseName:_databaseNameOrNil
                                                               networkManager:_networkManager];
    }
    
    return self;
}



#pragma mark - ICDRequestAllDocumentsDelegate methods
- (void)requestAllDocuments:(id<ICDRequestProtocol>)request didGetDocuments:(NSArray *)documents
{
    self.isRefreshingDesignDocs = NO;
    
    // Update data
    [self recreateOptionsWithDesignDocs:documents];
    
    // Notify
    if (self.delegate)
    {
        [self.delegate icdControllerOneDatabaseData:self didRefreshDesignDocsWithResult:YES];
    }
}

- (void)requestAllDocuments:(id<ICDRequestProtocol>)request didFailWithError:(NSError *)error
{
    ICDLogError(@"Error: %@", error);
    
    self.isRefreshingDesignDocs = NO;
    
    // Notify
    if (self.delegate)
    {
        [self.delegate icdControllerOneDatabaseData:self didRefreshDesignDocsWithResult:NO];
    }
}


#pragma mark - Public methods
- (NSInteger)numberOfOptions
{
    return [self.options count];
}

- (id<ICDControllerOneDatabaseOptionProtocol>)optionAtIndex:(NSUInteger)index
{
    return (id<ICDControllerOneDatabaseOptionProtocol>)self.options[index];
}

- (BOOL)asyncRefreshDesignDocs
{
    self.isRefreshingDesignDocs = [self executeRequestAllDesignDocs];
    if (self.isRefreshingDesignDocs && self.delegate)
    {
        [self.delegate icdControllerOneDatabaseDataWillRefreshDesignDocs:self];
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

- (void)recreateOptionsWithDesignDocs:(NSArray *)designDocs
{
    [self releaseOptions];
    
    NSMutableArray *nextOptions = [ICDControllerOneDatabaseData basicOptionsWithDatabaseName:self.databaseNameOrNil
                                                                              networkManager:self.networkManager];
    for (ICDModelDocument *oneDocument in designDocs)
    {
        [nextOptions addObject:[ICDControllerOneDatabaseOptionDesignDoc optionWithDesignDoc:oneDocument
                                                                               databaseName:self.databaseNameOrNil
                                                                             networkManager:self.networkManager]];
    }
    
    _options = nextOptions;
}

- (void)releaseOptions
{
    if (_options)
    {
        _options = nil;
    }
}


#pragma mark - Private class methods
+ (NSMutableArray *)basicOptionsWithDatabaseName:(NSString *)databaseNameOrNil
                                  networkManager:(id<ICDNetworkManagerProtocol>)networkManager
{
    ICDControllerOneDatabaseOptionAllDocs *allDocs = [ICDControllerOneDatabaseOptionAllDocs optionWithDatabaseName:databaseNameOrNil
                                                                                                    networkManager:networkManager];
    ICDControllerOneDatabaseOptionAllDesignDocs *allDesigns = [ICDControllerOneDatabaseOptionAllDesignDocs optionWithDatabaseName:databaseNameOrNil
                                                                                                                   networkManager:networkManager];
    
    return [NSMutableArray arrayWithObjects:allDocs, allDesigns, nil];
}

@end
