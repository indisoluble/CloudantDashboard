//
//  ICDControllerDocumentsData.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 04/01/2015.
//  Copyright (c) 2015 Enrique de la Torre. All rights reserved.
//

#import "ICDControllerDocumentsData.h"

#import "ICDNetworkManagerFactory.h"

#import "ICDRequestAllDocuments.h"
#import "ICDRequestCreateDocument.h"
#import "ICDRequestDeleteDocument.h"
#import "ICDRequestAddRevisionNotification.h"

#import "ICDLog.h"



@interface ICDControllerDocumentsData ()
    <ICDRequestAllDocumentsDelegate,
    ICDRequestCreateDocumentDelegate,
    ICDRequestDeleteDocumentDelegate>
{
    id<ICDNetworkManagerProtocol> _networkManager;
}

@property (strong, nonatomic) NSString *databaseName;
@property (strong, nonatomic) id<ICDNetworkManagerProtocol> networkManager;

@property (assign, nonatomic) BOOL isRefreshingDocs;

@property (strong, nonatomic) NSMutableArray *ongoingRequests;

@property (strong, nonatomic) NSMutableArray *allDocuments;

@property (assign, nonatomic) BOOL allObserversAdded;

@end



@implementation ICDControllerDocumentsData

#pragma mark - Synthesize properties
- (id<ICDNetworkManagerProtocol>)networkManager
{
    if (!_networkManager)
    {
        _networkManager = [ICDNetworkManagerFactory networkManager];
    }
    
    return _networkManager;
}

- (void)setNetworkManager:(id<ICDNetworkManagerProtocol>)networkManager
{
    _networkManager = (networkManager ? networkManager : [ICDNetworkManagerFactory networkManager]);
}


#pragma mark - Init object
- (id)init
{
    self = [super init];
    if (self)
    {
        _databaseName = nil;
        _networkManager = nil;
        
        _isRefreshingDocs = NO;
        
        _ongoingRequests = [NSMutableArray array];
        
        _allDocuments = [NSMutableArray array];
        
        _allObserversAdded = NO;
    }
    
    return self;
}


#pragma mark - Memory management
- (void)dealloc
{
    [self removeAllObservers];
}


#pragma mark - ICDRequestAllDocumentsForADatabaseDelegate methods
- (void)requestAllDocuments:(id<ICDRequestProtocol>)request didGetDocuments:(NSArray *)documents
{
    [self.ongoingRequests removeObject:request];
    
    self.isRefreshingDocs = NO;
    
    // Update data
    self.allDocuments = [NSMutableArray arrayWithArray:documents];
    [self.allDocuments sortUsingSelector:@selector(compare:)];
    
    // Notify
    if (self.delegate)
    {
        [self.delegate icdControllerDocumentsData:self didRefreshDocsWithResult:YES];
    }
}

- (void)requestAllDocuments:(id<ICDRequestProtocol>)request didFailWithError:(NSError *)error
{
    ICDLogError(@"Error: %@", error);
    
    [self.ongoingRequests removeObject:request];
    
    self.isRefreshingDocs = NO;
    
    // Notify
    if (self.delegate)
    {
        [self.delegate icdControllerDocumentsData:self didRefreshDocsWithResult:NO];
    }
}


#pragma mark - ICDRequestCreateDocumentDelegate methods
- (void)requestCreateDocument:(id<ICDRequestProtocol>)request didCreateDocument:(ICDModelDocument *)document
{
    [self.ongoingRequests removeObject:request];
    
    // Update data
    NSUInteger index = [self.allDocuments indexOfObject:document
                                          inSortedRange:NSMakeRange(0, [self.allDocuments count])
                                                options:NSBinarySearchingInsertionIndex
                                        usingComparator:^NSComparisonResult(id obj1, id obj2) {
                                            return [(ICDModelDocument *)obj1 compare:(ICDModelDocument *)obj2];
                                        }];
    [self.allDocuments insertObject:document atIndex:index];
    
    // Notify
    if (self.delegate)
    {
        [self.delegate icdControllerDocumentsData:self didCreateDocAtIndex:index];
    }
}

- (void)requestCreateDocument:(id<ICDRequestProtocol>)request didFailWithError:(NSError *)error
{
    ICDLogError(@"Error: %@", error);
    
    [self.ongoingRequests removeObject:request];
}


#pragma mark - ICDRequestDeleteDocumentDelegate methods
- (void)requestDeleteDocument:(id<ICDRequestProtocol>)request
      didDeleteDocumentWithId:(NSString *)docId
                     revision:(NSString *)docRev
{
    [self.ongoingRequests removeObject:request];
    
    // Update data
    ICDModelDocument *document = [ICDModelDocument documentWithId:docId rev:docRev];
    NSUInteger index = [self.allDocuments indexOfObject:document];
    if (index == NSNotFound)
    {
        ICDLogError(@"Document <%@> is not in the list. Abort", document);
        
        return;
    }
    
    [self.allDocuments removeObjectAtIndex:index];
    
    // Notify
    if (self.delegate)
    {
        [self.delegate icdControllerDocumentsData:self didDeleteDocAtIndex:index];
    }
}

- (void)requestDeleteDocument:(id<ICDRequestProtocol>)request
             didFailWithError:(NSError *)error
{
    ICDLogError(@"Error: %@", error);
    
    [self.ongoingRequests removeObject:request];
}


#pragma mark - Public methods
- (NSInteger)numberOfDocuments
{
    return [self.allDocuments count];
}

- (ICDModelDocument *)documentAtIndex:(NSUInteger)index
{
    return (ICDModelDocument *)self.allDocuments[index];
}

- (BOOL)asyncRefreshDocsWithNetworkManager:(id<ICDNetworkManagerProtocol>)networkManager
                              databaseName:(NSString *)databaseName
{
    [self useNetworkManager:networkManager databaseName:databaseName];
    
    return [self asyncRefreshDocs];
}

- (BOOL)asyncRefreshDocs
{
    self.isRefreshingDocs = [self executeRequestAllDocs];
    if (self.isRefreshingDocs && self.delegate)
    {
        [self.delegate icdControllerDocumentsDataWillRefreshDocs:self];
    }
    
    return self.isRefreshingDocs;
}

- (BOOL)asyncCreateDoc
{
    return [self executeRequestCreateDoc];
}

- (BOOL)asyncDeleteDocAtIndex:(NSUInteger)index
{
    ICDModelDocument *document = [self documentAtIndex:index];
    
    return [self executeRequestDeleteDocWithData:document];
}

- (void)reset
{
    [self removeAllObservers];
    
    [self releaseOngoingRequests];
    
    self.isRefreshingDocs = NO;
    
    self.networkManager = nil;
    
    self.databaseName = nil;
}


#pragma mark - Private methods
- (void)useNetworkManager:(id<ICDNetworkManagerProtocol>)networkManager
             databaseName:(NSString *)databaseName
{
    [self reset];
    
    self.databaseName = databaseName;
    
    self.networkManager = networkManager;
    
    if (self.databaseName)
    {
        [self addAllObservers];
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

- (void)addAllObservers
{
    if (!self.allObserversAdded)
    {
        [[ICDRequestAddRevisionNotification sharedInstance] addDidAddRevisionNotificationObserver:self
                                                                                         selector:@selector(didReceiveDidAddRevisionNotification:)];
        
        self.allObserversAdded = YES;
    }
}

- (void)removeAllObservers
{
    if (self.allObserversAdded)
    {
        [[ICDRequestAddRevisionNotification sharedInstance] removeDidAddRevisionNotificationObserver:self];
        
        self.allObserversAdded = NO;
    }
}

- (void)didReceiveDidAddRevisionNotification:(NSNotification *)notification
{
    ICDLogDebug(@"didAddRevision Notification: %@", notification);
    
    // Validate
    NSString *dbName = notification.userInfo[kICDRequestAddRevisionNotificationDidAddRevisionUserInfoKeyDatabaseName];
    if (![self.databaseName isEqualToString:dbName])
    {
        ICDLogDebug(@"Revision added to a document in another database. Ignore");
        
        return;
    }
    
    ICDModelDocument *revision = notification.userInfo[kICDRequestAddRevisionNotificationDidAddRevisionUserInfoKeyRevision];
    
    NSUInteger index = [self.allDocuments indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        ICDModelDocument *otherDocument = (ICDModelDocument *)obj;
        if ([otherDocument.documentId isEqualToString:revision.documentId])
        {
            *stop = YES;
            
            return YES;
        }
        
        return NO;
    }];
    
    if (index == NSNotFound)
    {
        ICDLogWarning(@"No document for this revision: %@", revision);
        
        return;
    }
    
    // Update data
    [self.allDocuments replaceObjectAtIndex:index withObject:revision];
    
    // Notify
    if (self.delegate)
    {
        [self.delegate icdControllerDocumentsData:self didUpdateDocAtIndex:index];
    }
}

- (BOOL)executeRequestAllDocs
{
    ICDRequestAllDocuments *requestAllDocs = [[ICDRequestAllDocuments alloc] initWithDatabaseName:self.databaseName];
    if (!requestAllDocs)
    {
        ICDLogWarning(@"Request not created with database name <%@>. Abort", self.databaseName);
        
        return NO;
    }
    
    requestAllDocs.delegate = self;
    
    BOOL success = [self.networkManager asyncExecuteRequest:requestAllDocs];
    if (success)
    {
        [self.ongoingRequests addObject:requestAllDocs];
    }
    
    return success;
}

- (BOOL)executeRequestCreateDoc
{
    ICDRequestCreateDocument *requestCreateDoc = [[ICDRequestCreateDocument alloc] initWithDatabaseName:self.databaseName];
    if (!requestCreateDoc)
    {
        ICDLogWarning(@"Request not created with database name <%@>. Abort", self.databaseName);
        
        return NO;
    }
    
    requestCreateDoc.delegate = self;
    
    BOOL success = [self.networkManager asyncExecuteRequest:requestCreateDoc];
    if (success)
    {
        [self.ongoingRequests addObject:requestCreateDoc];
    }
    
    return success;
}

- (BOOL)executeRequestDeleteDocWithData:(ICDModelDocument *)document
{
    ICDRequestDeleteDocument *requestDeleteDoc = [[ICDRequestDeleteDocument alloc] initWithDatabaseName:self.databaseName
                                                                                             documentId:document.documentId
                                                                                            documentRev:document.documentRev];
    if (!requestDeleteDoc)
    {
        ICDLogWarning(@"Request not created with database name <%@> and document <%@>. Abort", self.databaseName, document);
        
        return NO;
    }
    
    requestDeleteDoc.delegate = self;
    
    BOOL success = [self.networkManager asyncExecuteRequest:requestDeleteDoc];
    if (success)
    {
        [self.ongoingRequests addObject:requestDeleteDoc];
    }
    
    return YES;
}

@end
