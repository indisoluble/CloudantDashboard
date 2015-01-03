//
//  ICDControllerDocumentsTVC.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 23/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import "ICDControllerDocumentsTVC.h"

#import "ICDControllerDocumentVC.h"

#import "ICDNetworkManagerFactory.h"

#import "ICDRequestAllDocuments.h"
#import "ICDRequestCreateDocument.h"
#import "ICDRequestDeleteDocument.h"
#import "ICDRequestAddRevisionNotification.h"

#import "ICDModelDocument.h"

#import "ICDLog.h"
#import "ICDCommonAnimationDuration.h"



NSString * const kICDDocumentsTVCCellID = @"documentCell";



@interface ICDControllerDocumentsTVC ()
    <ICDRequestAllDocumentsDelegate,
    ICDRequestCreateDocumentDelegate,
    ICDRequestDeleteDocumentDelegate>
{
    id<ICDNetworkManagerProtocol> _networkManager;
}

@property (strong, nonatomic) id<ICDNetworkManagerProtocol> networkManager;

@property (strong, nonatomic) NSMutableArray *ongoingRequests;

@property (strong, nonatomic) NSString *databaseName;

@property (strong, nonatomic) NSMutableArray *allDocuments;

@property (assign, nonatomic) BOOL isViewVisible;

@end



@implementation ICDControllerDocumentsTVC

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
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        _ongoingRequests = [NSMutableArray array];
        _allDocuments = [NSMutableArray array];
        
        _isViewVisible = NO;
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
    
    self.clearsSelectionOnViewWillAppear = NO;
    
    [self customizeUI];
    
    [self addAllObservers];
    
    if ([self.ongoingRequests count] > 0)
    {
        [self forceShowRefreshControlAnimation];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.isViewVisible = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.isViewVisible = NO;
    
    if ([self isMovingFromParentViewController])
    {
        [self removeAllObservers];
    }
}


#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]] &&
        [segue.destinationViewController isKindOfClass:[ICDControllerDocumentVC class]])
    {
        [self prepareForSegueDocumentVC:segue.destinationViewController withCell:sender];
    }
}


#pragma mark - UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.allDocuments count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ICDModelDocument *document = (ICDModelDocument *)self.allDocuments[indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kICDDocumentsTVCCellID forIndexPath:indexPath];
    cell.textLabel.text = document.documentId;
    cell.detailTextLabel.text = document.documentRev;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    ICDModelDocument *document = (ICDModelDocument *)self.allDocuments[indexPath.row];
    
    [self executeRequestDeleteDocWithData:document];
}


#pragma mark - ICDRequestAllDocumentsForADatabaseDelegate methods
- (void)requestAllDocuments:(id<ICDRequestProtocol>)request didGetDocuments:(NSArray *)documents
{
    NSUInteger index = [self.ongoingRequests indexOfObject:request];
    if (index == NSNotFound)
    {
        ICDLogDebug(@"Received documents from unexpected request. Ignore");
        
        return;
    }
    
    [self releaseOngoingRequestAtIndex:index];
    
    // Update data
    self.allDocuments = [NSMutableArray arrayWithArray:documents];
    [self.allDocuments sortUsingSelector:@selector(compare:)];
    
    // Refresh UI
    if ([self isViewLoaded])
    {
        [self.tableView reloadData];
        
        [self.refreshControl endRefreshing];
    }
}

- (void)requestAllDocuments:(id<ICDRequestProtocol>)request didFailWithError:(NSError *)error
{
    NSUInteger index = [self.ongoingRequests indexOfObject:request];
    if (index == NSNotFound)
    {
        ICDLogDebug(@"Received error from unexpected request. Ignore");
        
        return;
    }
    
    ICDLogError(@"Error: %@", error);
    
    [self releaseOngoingRequestAtIndex:index];
    
    if ([self isViewLoaded])
    {
        [self.refreshControl endRefreshing];
    }
}


#pragma mark - ICDRequestCreateDocumentDelegate methods
- (void)requestCreateDocument:(id<ICDRequestProtocol>)request didCreateDocument:(ICDModelDocument *)document
{
    NSUInteger index = [self.ongoingRequests indexOfObject:request];
    if (index == NSNotFound)
    {
        ICDLogDebug(@"Received document from unexpected request. Ignore");
        
        return;
    }
    
    [self releaseOngoingRequestAtIndex:index];
    
    // Update data
    index = [self.allDocuments indexOfObject:document
                               inSortedRange:NSMakeRange(0, [self.allDocuments count])
                                     options:NSBinarySearchingInsertionIndex
                             usingComparator:^NSComparisonResult(id obj1, id obj2) {
                                 return [(ICDModelDocument *)obj1 compare:(ICDModelDocument *)obj2];
                             }];
    [self.allDocuments insertObject:document atIndex:index];
    
    // Refresh UI
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
    if (self.isViewVisible)
    {
        [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
    }
}

- (void)requestCreateDocument:(id<ICDRequestProtocol>)request didFailWithError:(NSError *)error
{
    NSUInteger index = [self.ongoingRequests indexOfObject:request];
    if (index == NSNotFound)
    {
        ICDLogDebug(@"Received error from unexpected request. Ignore");
        
        return;
    }
    
    ICDLogError(@"Error: %@", error);
    
    [self releaseOngoingRequestAtIndex:index];
}


#pragma mark - ICDRequestDeleteDocumentDelegate methods
- (void)requestDeleteDocument:(id<ICDRequestProtocol>)request
      didDeleteDocumentWithId:(NSString *)docId
                     revision:(NSString *)docRev
{
    NSUInteger index = [self.ongoingRequests indexOfObject:request];
    if (index == NSNotFound)
    {
        ICDLogDebug(@"Received deleted document from unexpected request. Ignore");
        
        return;
    }
    
    [self releaseOngoingRequestAtIndex:index];
    
    // Update data
    ICDModelDocument *document = [ICDModelDocument documentWithId:docId rev:docRev];
    index = [self.allDocuments indexOfObject:document];
    if (index == NSNotFound)
    {
        ICDLogError(@"Document <%@> is not in the list. Abort", document);
        
        return;
    }
    
    [self.allDocuments removeObjectAtIndex:index];
    
    // Refresh UI
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)requestDeleteDocument:(id<ICDRequestProtocol>)request
             didFailWithError:(NSError *)error
{
    NSUInteger index = [self.ongoingRequests indexOfObject:request];
    if (index == NSNotFound)
    {
        ICDLogDebug(@"Received error from unexpected request. Ignore");
        
        return;
    }
    
    ICDLogError(@"Error: %@", error);
    
    [self releaseOngoingRequestAtIndex:index];
}


#pragma mark - Public methods
- (void)useNetworkManager:(id<ICDNetworkManagerProtocol>)networkManager
             databaseName:(NSString *)databaseName
{
    if (databaseName)
    {
        self.title = databaseName;
    }
    
    self.networkManager = networkManager;
    
    [self releaseOngoingRequests];
    
    self.databaseName = databaseName;
    
    [self executeRequestAllDocsForceShowAnimation:YES];
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
                                                                          action:@selector(executeRequestCreateDoc)];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)addRefreshControl
{
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self
                       action:@selector(executeRequestAllDocsAfterPullingToRefresh)
             forControlEvents:UIControlEventValueChanged];
    
    self.refreshControl = refreshControl;
}

- (void)executeRequestAllDocsAfterPullingToRefresh
{
    if (![self executeRequestAllDocsForceShowAnimation:NO])
    {
        [self.refreshControl endRefreshing];
    }
}

- (void)forceShowRefreshControlAnimation
{
    [self.refreshControl beginRefreshing];
    
    if (self.tableView.contentOffset.y == 0)
    {
        __weak ICDControllerDocumentsTVC *weakSelf = self;
        void (^animationBlock)(void) = ^(void)
        {
            __strong ICDControllerDocumentsTVC *strongSelf = weakSelf;
            if (strongSelf)
            {
                strongSelf.tableView.contentOffset = CGPointMake(0, -strongSelf.refreshControl.frame.size.height);
            }
        };
        
        [UIView animateWithDuration:ICDCOMMONANIMATIONDURATION_REFRESHCONTROL
                              delay:0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:animationBlock
                         completion:nil];
        
    }
}

- (void)removeAllObservers
{
    [[ICDRequestAddRevisionNotification sharedInstance] removeDidAddRevisionNotificationObserver:self];
}

- (void)addAllObservers
{
    [[ICDRequestAddRevisionNotification sharedInstance] addDidAddRevisionNotificationObserver:self
                                                                                     selector:@selector(didReceiveDidAddRevisionNotification:)];
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
    
    // Refresh UI
    NSIndexPath *indexPathForSelectedRow = [self.tableView indexPathForSelectedRow];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
    if ([indexPath isEqual:indexPathForSelectedRow])
    {
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}

- (void)releaseOngoingRequests
{
    NSUInteger count = [self.ongoingRequests count];
    for (NSUInteger index = 0; index < count; index++)
    {
        [self releaseOngoingRequestAtIndex:index];
    }
}

- (void)releaseOngoingRequestAtIndex:(NSUInteger)index
{
    id oneRequest = [self.ongoingRequests objectAtIndex:index];
    if ([oneRequest respondsToSelector:@selector(setDelegate:)])
    {
        [oneRequest setDelegate:nil];
    }
    
    [self.ongoingRequests removeObjectAtIndex:index];
}

- (BOOL)executeRequestAllDocsForceShowAnimation:(BOOL)forceShowAnimation
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
        
        if (forceShowAnimation && [self isViewLoaded])
        {
            [self forceShowRefreshControlAnimation];
        }
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

- (void)prepareForSegueDocumentVC:(ICDControllerDocumentVC *)documentVC
                         withCell:(UITableViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    ICDModelDocument *document = (ICDModelDocument *)self.allDocuments[indexPath.row];
    
    [documentVC useNetworkManager:self.networkManager
                     databaseName:self.databaseName
                         document:document];
}

@end
