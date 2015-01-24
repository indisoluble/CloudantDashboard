//
//  ICDControllerDocumentsDataDocsInDesignDocView.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 24/01/2015.
//  Copyright (c) 2015 Enrique de la Torre. All rights reserved.
//

#import "ICDControllerDocumentsDataDocsInDesignDocView.h"

#import "ICDNetworkManagerFactory.h"

#import "ICDRequestDocsInDesignDocView.h"
#import "ICDRequestAddRevisionNotification.h"

#import "ICDLog.h"



@interface ICDControllerDocumentsDataDocsInDesignDocView () <ICDRequestDocsInDesignDocViewDelegate>

@property (strong, nonatomic, readonly) NSString *designDocIdOrNil;
@property (strong, nonatomic, readonly) NSString *viewnameOrNil;

@property (assign, nonatomic) BOOL isRefreshingDocs;

@property (strong, nonatomic) NSMutableArray *allDocuments;

@property (assign, nonatomic) BOOL didAddRevisionObserverAdded;

@end



@implementation ICDControllerDocumentsDataDocsInDesignDocView

#pragma mark - Synthesize properties
@synthesize databaseNameOrNil = _databaseNameOrNil;
@synthesize networkManager = _networkManager;

@synthesize delegate = _delegate;


#pragma mark - Init
- (id)init
{
    return [self initWithDatabaseName:nil designDoc:nil designDocView:nil networkManager:nil];
}

- (id)initWithDatabaseName:(NSString *)databaseNameOrNil
                 designDoc:(ICDModelDocument *)designDocOrNil
             designDocView:(ICDModelDesignDocumentView *)designDocViewOrNil
            networkManager:(id<ICDNetworkManagerProtocol>)networkManagerOrNil;
{
    self = [super init];
    if (self)
    {
        _databaseNameOrNil = databaseNameOrNil;
        _designDocIdOrNil = (designDocOrNil ? designDocOrNil.documentId : nil);
        _viewnameOrNil = (designDocViewOrNil ? designDocViewOrNil.viewname : nil);
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
    self.isRefreshingDocs = [self executeRequestDocInDesignView];
    if (self.isRefreshingDocs && self.delegate)
    {
        [self.delegate icdControllerDocumentsDataWillRefreshDocs:self];
    }
    
    return self.isRefreshingDocs;
}


#pragma mark - ICDRequestDocsInDesignDocViewDelegate methods
- (void)requestDocsInDesignDocView:(id<ICDRequestProtocol>)request didGetDocuments:(NSArray *)documents
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

- (void)requestDocsInDesignDocView:(id<ICDRequestProtocol>)request didFailWithError:(NSError *)error
{
    ICDLogError(@"Error: %@", error);
    
    self.isRefreshingDocs = NO;
    
    // Notify
    if (self.delegate)
    {
        [self.delegate icdControllerDocumentsData:self didRefreshDocsWithResult:NO];
    }
}


#pragma mark - Private methods
- (BOOL)executeRequestDocInDesignView
{
    ICDRequestDocsInDesignDocView *requestDocsInDesignView = [[ICDRequestDocsInDesignDocView alloc] initWithDatabaseName:self.databaseNameOrNil
                                                                                                             designDocId:self.designDocIdOrNil
                                                                                                                viewname:self.viewnameOrNil];
    if (!requestDocsInDesignView)
    {
        ICDLogWarning(@"Request not created with <%@, %@, %@>. Abort", self.databaseNameOrNil, self.designDocIdOrNil, self.viewnameOrNil);
        
        return NO;
    }
    
    requestDocsInDesignView.delegate = self;
    
    return [self.networkManager asyncExecuteRequest:requestDocsInDesignView];
}

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

@end
