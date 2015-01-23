//
//  ICDControllerDocumentsDataAllDocuments.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 04/01/2015.
//  Copyright (c) 2015 Enrique de la Torre. All rights reserved.
//

#import "ICDControllerDocumentsDataAllDocuments.h"

#import "ICDNetworkManagerFactory.h"

#import "ICDRequestAllDocuments.h"
#import "ICDRequestCreateDocument.h"
#import "ICDRequestBulkDocuments.h"
#import "ICDRequestDeleteDocument.h"
#import "ICDRequestAddRevisionNotification.h"

#import "ICDLog.h"



@interface ICDControllerDocumentsDataAllDocuments ()
    <ICDRequestAllDocumentsDelegate,
    ICDRequestCreateDocumentDelegate,
    ICDRequestBulkDocumentsDelegate,
    ICDRequestDeleteDocumentDelegate>

@property (assign, nonatomic) BOOL isRefreshingDocs;

@property (strong, nonatomic) NSMutableArray *allDocuments;

@property (assign, nonatomic) BOOL didAddRevisionObserverAdded;

@end



@implementation ICDControllerDocumentsDataAllDocuments

#pragma mark - Synthesize properties
@synthesize databaseNameOrNil = _databaseNameOrNil;
@synthesize networkManager = _networkManager;

@synthesize delegate = _delegate;


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
        
        _isRefreshingDocs = NO;
        
        _allDocuments = [NSMutableArray array];
        
        _didAddRevisionObserverAdded = NO;
    }
    
    return self;
}


#pragma mark - Memory management
- (void)dealloc
{
    [self removeObserverForDidAddRevisionNotification];
}


#pragma mark - ICDControllerDocumentsDataProtocol methods
- (NSInteger)numberOfDocuments
{
    return [self.allDocuments count];
}

- (ICDModelDocument *)documentAtIndex:(NSUInteger)index
{
    return (ICDModelDocument *)self.allDocuments[index];
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

- (BOOL)asyncBulkDocsWithData:(NSDictionary *)data
               numberOfCopies:(NSUInteger)numberOfCopies
{
    return [self executeRequestBulkDocsWithData:data numberOfCopies:numberOfCopies];
}

- (BOOL)asyncDeleteDocAtIndex:(NSUInteger)index
{
    ICDModelDocument *document = [self documentAtIndex:index];
    
    return [self executeRequestDeleteDocWithData:document];
}


#pragma mark - ICDRequestAllDocumentsDelegate methods
- (void)requestAllDocuments:(id<ICDRequestProtocol>)request didGetDocuments:(NSArray *)documents
{
    self.isRefreshingDocs = NO;
    
    [self addObserverForDidAddRevisionNotification];
    
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
    [self requestBulkDocuments:nil didBulkDocuments:@[document]];
}

- (void)requestCreateDocument:(id<ICDRequestProtocol>)request didFailWithError:(NSError *)error
{
    ICDLogError(@"Error: %@", error);
}


#pragma mark - ICDRequestBulkDocumentsDelegate methods
- (void)requestBulkDocuments:(id<ICDRequestProtocol>)request didBulkDocuments:(NSArray *)documents
{
    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
    
    // Update data
    NSUInteger index = 0;
    
    NSComparator comparator = ^NSComparisonResult(id obj1, id obj2)
    {
        return [(ICDModelDocument *)obj1 compare:(ICDModelDocument *)obj2];
    };
    
    for (ICDModelDocument *oneDocument in [documents sortedArrayUsingSelector:@selector(compare:)])
    {
        index = [self.allDocuments indexOfObject:oneDocument
                                   inSortedRange:NSMakeRange(0, [self.allDocuments count])
                                         options:NSBinarySearchingInsertionIndex
                                 usingComparator:comparator];
        [self.allDocuments insertObject:oneDocument atIndex:index];
        
        [indexes addIndex:index];
    }
    
    // Notify
    if (self.delegate)
    {
        [self.delegate icdControllerDocumentsData:self didCreateDocsAtIndexes:indexes];
    }
}

- (void)requestBulkDocuments:(id<ICDRequestProtocol>)request didFailWithError:(NSError *)error
{
    ICDLogError(@"Error: %@", error);
}


#pragma mark - ICDRequestDeleteDocumentDelegate methods
- (void)requestDeleteDocument:(id<ICDRequestProtocol>)request
      didDeleteDocumentWithId:(NSString *)docId
                     revision:(NSString *)docRev
{
    // Update data
    ICDModelDocument *document = [ICDModelDocument documentWithId:docId rev:docRev];
    
    NSComparator comparator = ^NSComparisonResult(id obj1, id obj2)
    {
        return [(ICDModelDocument *)obj1 compare:(ICDModelDocument *)obj2];
    };
    
    NSUInteger index = [self.allDocuments indexOfObject:document
                                          inSortedRange:NSMakeRange(0, [self.allDocuments count])
                                                options:kNilOptions
                                        usingComparator:comparator];
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
}


#pragma mark - Private methods
- (void)addObserverForDidAddRevisionNotification
{
    if (!self.didAddRevisionObserverAdded)
    {
        [[ICDRequestAddRevisionNotification sharedInstance] addDidAddRevisionNotificationObserver:self
                                                                                         selector:@selector(didReceiveDidAddRevisionNotification:)];
        
        self.didAddRevisionObserverAdded = YES;
    }
}

- (void)removeObserverForDidAddRevisionNotification
{
    if (self.didAddRevisionObserverAdded)
    {
        [[ICDRequestAddRevisionNotification sharedInstance] removeDidAddRevisionNotificationObserver:self];
        
        self.didAddRevisionObserverAdded = NO;
    }
}

- (void)didReceiveDidAddRevisionNotification:(NSNotification *)notification
{
    ICDLogDebug(@"didAddRevision Notification: %@", notification);
    
    // Validate
    NSString *dbName = notification.userInfo[kICDRequestAddRevisionNotificationDidAddRevisionUserInfoKeyDatabaseName];
    if (!self.databaseNameOrNil || ![self.databaseNameOrNil isEqualToString:dbName])
    {
        ICDLogDebug(@"Revision added to a document in another database. Ignore");
        
        return;
    }
    
    ICDModelDocument *revision = notification.userInfo[kICDRequestAddRevisionNotificationDidAddRevisionUserInfoKeyRevision];
    
    NSComparator comparator = ^NSComparisonResult(id obj1, id obj2)
    {
        return [[(ICDModelDocument *)obj1 documentId] compare:[(ICDModelDocument *)obj2 documentId]];
    };
    
    NSUInteger index = [self.allDocuments indexOfObject:revision
                                          inSortedRange:NSMakeRange(0, [self.allDocuments count])
                                                options:kNilOptions
                                        usingComparator:comparator];
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
    ICDRequestAllDocuments *requestAllDocs = [[ICDRequestAllDocuments alloc] initWithDatabaseName:self.databaseNameOrNil
                                                                                        arguments:nil];
    if (!requestAllDocs)
    {
        ICDLogWarning(@"Request not created with database name <%@>. Abort", self.databaseNameOrNil);
        
        return NO;
    }
    
    requestAllDocs.delegate = self;
    
    return [self.networkManager asyncExecuteRequest:requestAllDocs];
}

- (BOOL)executeRequestCreateDoc
{
    ICDRequestCreateDocument *requestCreateDoc = [[ICDRequestCreateDocument alloc] initWithDatabaseName:self.databaseNameOrNil];
    if (!requestCreateDoc)
    {
        ICDLogWarning(@"Request not created with database name <%@>. Abort", self.databaseNameOrNil);
        
        return NO;
    }
    
    requestCreateDoc.delegate = self;
    
    return [self.networkManager asyncExecuteRequest:requestCreateDoc];
}

- (BOOL)executeRequestBulkDocsWithData:(NSDictionary *)data
                        numberOfCopies:(NSUInteger)numberOfCopies
{
    ICDRequestBulkDocuments *requestBulkDocs = [[ICDRequestBulkDocuments alloc] initWithDatabaseName:self.databaseNameOrNil
                                                                                        documentData:data
                                                                                      numberOfCopies:numberOfCopies];
    if (!requestBulkDocs)
    {
        ICDLogWarning(@"Request not created with database name <%@>. Abort", self.databaseNameOrNil);
        
        return NO;
    }
    
    requestBulkDocs.delegate = self;
    
    return [self.networkManager asyncExecuteRequest:requestBulkDocs];
}

- (BOOL)executeRequestDeleteDocWithData:(ICDModelDocument *)document
{
    ICDRequestDeleteDocument *requestDeleteDoc = [[ICDRequestDeleteDocument alloc] initWithDatabaseName:self.databaseNameOrNil
                                                                                             documentId:document.documentId
                                                                                            documentRev:document.documentRev];
    if (!requestDeleteDoc)
    {
        ICDLogWarning(@"Request not created with database name <%@> and document <%@>. Abort", self.databaseNameOrNil, document);
        
        return NO;
    }
    
    requestDeleteDoc.delegate = self;
    
    return [self.networkManager asyncExecuteRequest:requestDeleteDoc];
}

@end
