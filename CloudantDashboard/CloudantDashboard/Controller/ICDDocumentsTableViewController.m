//
//  ICDDocumentsTableViewController.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 23/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import "ICDDocumentsTableViewController.h"

#import "ICDDocumentViewController.h"

#import "ICDRequestAllDocuments.h"
#import "ICDRequestCreateDocument.h"
#import "ICDRequestDeleteDocument.h"

#import "ICDModelDocument.h"

#import "ICDLog.h"
#import "ICDCommonAnimationDuration.h"



NSString * const kICDDocumentsTVCCellID = @"documentCell";



@interface ICDDocumentsTableViewController ()
    <ICDRequestAllDocumentsDelegate,
    ICDRequestCreateDocumentDelegate,
    ICDRequestDeleteDocumentDelegate,
    ICDDocumentViewControllerDelegate>

@property (strong, nonatomic) ICDNetworkManager *networkManager;

@property (strong, nonatomic) ICDRequestAllDocuments *requestAllDocs;
@property (strong, nonatomic) ICDRequestCreateDocument *requestCreateDoc;
@property (strong, nonatomic) ICDRequestDeleteDocument *requestDeleteDoc;

@property (strong, nonatomic) NSString *databaseName;

@property (strong, nonatomic) NSMutableArray *allDocuments;

@property (assign, nonatomic) BOOL isViewVisible;

@end



@implementation ICDDocumentsTableViewController

#pragma mark - Init object
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
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
    
    if (self.requestAllDocs)
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
}


#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]] &&
        [segue.destinationViewController isKindOfClass:[ICDDocumentViewController class]])
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
    if (request != self.requestAllDocs)
    {
        ICDLogDebug(@"Received documents from unexpected request. Ignore");
        
        return;
    }
    
    [self releaseRequestAllDocs];
    
    self.allDocuments = [NSMutableArray arrayWithArray:documents];
    [self.allDocuments sortUsingSelector:@selector(compare:)];
    
    if ([self isViewLoaded])
    {
        [self.refreshControl endRefreshing];
        [self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:ICDCOMMONANIMATIONDURATION_REFRESHCONTROL];
    }
}

- (void)requestAllDocuments:(id<ICDRequestProtocol>)request didFailWithError:(NSError *)error
{
    if (request != self.requestAllDocs)
    {
        ICDLogDebug(@"Received error from unexpected request. Ignore");
        
        return;
    }
    
    ICDLogError(@"Error: %@", error);
    
    [self releaseRequestAllDocs];
    
    if ([self isViewLoaded])
    {
        [self.refreshControl endRefreshing];
    }
}


#pragma mark - ICDRequestCreateDocumentDelegate methods
- (void)requestCreateDocument:(id<ICDRequestProtocol>)request didCreateDocument:(ICDModelDocument *)document
{
    if (request != self.requestCreateDoc)
    {
        ICDLogDebug(@"Received document from unexpected request. Ignore");
        
        return;
    }
    
    [self releaseRequestCreateDoc];
    
    NSUInteger index = [self.allDocuments indexOfObject:document
                                          inSortedRange:NSMakeRange(0, [self.allDocuments count])
                                                options:NSBinarySearchingInsertionIndex
                                        usingComparator:^NSComparisonResult(id obj1, id obj2) {
                                            return [(ICDModelDocument *)obj1 compare:(ICDModelDocument *)obj2];
                                        }];
    [self.allDocuments insertObject:document atIndex:index];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
    if (self.isViewVisible)
    {
        [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
    }
}

- (void)requestCreateDocument:(id<ICDRequestProtocol>)request didFailWithError:(NSError *)error
{
    if (request != self.requestCreateDoc)
    {
        ICDLogDebug(@"Received error from unexpected request. Ignore");
        
        return;
    }
    
    ICDLogError(@"Error: %@", error);
    
    [self releaseRequestCreateDoc];
}


#pragma mark - ICDRequestDeleteDocumentDelegate methods
- (void)requestDeleteDocument:(id<ICDRequestProtocol>)request
      didDeleteDocumentWithId:(NSString *)docId
                     revision:(NSString *)docRev
{
    if (request != self.requestDeleteDoc)
    {
        ICDLogDebug(@"Received deleted document from unexpected request. Ignore");
        
        return;
    }
    
    [self releaseRequestDeleteDoc];
    
    ICDModelDocument *document = [ICDModelDocument documentWithId:docId rev:docRev];
    NSUInteger index = [self.allDocuments indexOfObject:document];
    if (index == NSNotFound)
    {
        ICDLogError(@"Document <%@> is not in the list. Abort", document);
        
        return;
    }
    
    [self.allDocuments removeObjectAtIndex:index];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)requestDeleteDocument:(id<ICDRequestProtocol>)request
             didFailWithError:(NSError *)error
{
    if (request != self.requestDeleteDoc)
    {
        ICDLogDebug(@"Received error from unexpected request. Ignore");
        
        return;
    }
    
    ICDLogError(@"Error: %@", error);
    
    [self releaseRequestDeleteDoc];
}


#pragma mark - ICDDocumentViewControllerDelegate methods
- (void)icdDocumentVC:(ICDDocumentViewController *)vc didAddRevision:(ICDModelDocument *)revision
{
    NSUInteger index = [self.allDocuments indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        ICDModelDocument *otherDocument = (ICDModelDocument *)obj;
        if ([otherDocument.documentId isEqualToString:revision.documentId])
        {
            *stop = YES;
            
            return YES;
        }
        
        return NO;
    }];
    
    if (index != NSNotFound)
    {
        [self.allDocuments replaceObjectAtIndex:index withObject:revision];
        
        NSIndexPath *indexPathForSelectedRow = [self.tableView indexPathForSelectedRow];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        
        if ([indexPath isEqual:indexPathForSelectedRow])
        {
            [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    }
}


#pragma mark - Public methods
- (void)useNetworkManager:(ICDNetworkManager *)networkManager
             databaseName:(NSString *)databaseName
{
    if (databaseName)
    {
        self.title = databaseName;
    }
    
    self.networkManager = networkManager;
    self.databaseName = databaseName;
    
    [self releaseRequestAllDocs];
    [self releaseRequestCreateDoc];
    [self releaseRequestDeleteDoc];
    
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
        __weak ICDDocumentsTableViewController *weakSelf = self;
        void (^animationBlock)(void) = ^(void)
        {
            __strong ICDDocumentsTableViewController *strongSelf = weakSelf;
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

- (BOOL)executeRequestAllDocsForceShowAnimation:(BOOL)forceShowAnimation
{
    if ([self isExecutingRequest])
    {
        ICDLogTrace(@"There is a request ongoing. Abort");
        
        return NO;
    }
    
    if (!self.networkManager)
    {
        ICDLogTrace(@"No network manager. Abort");
        
        return NO;
    }
    
    self.requestAllDocs = [[ICDRequestAllDocuments alloc] initWithDatabaseName:self.databaseName];
    if (!self.requestAllDocs)
    {
        ICDLogWarning(@"Request not created with database name <%@>. Abort", self.databaseName);
        
        return NO;
    }
    
    self.requestAllDocs.delegate = self;
    
    if (forceShowAnimation && [self isViewLoaded])
    {
        [self forceShowRefreshControlAnimation];
    }
    
    [self.networkManager executeRequest:self.requestAllDocs];
    
    return YES;
}

- (void)releaseRequestAllDocs
{
    if (self.requestAllDocs)
    {
        self.requestAllDocs.delegate = nil;
        self.requestAllDocs = nil;
    }
}

- (BOOL)executeRequestCreateDoc
{
    if ([self isExecutingRequest])
    {
        ICDLogTrace(@"There is a request ongoing. Abort");
        
        return NO;
    }
    
    if (!self.networkManager)
    {
        ICDLogTrace(@"No network manager. Abort");
        
        return NO;
    }
    
    self.requestCreateDoc = [[ICDRequestCreateDocument alloc] initWithDatabaseName:self.databaseName];
    if (!self.requestCreateDoc)
    {
        ICDLogWarning(@"Request not created with database name <%@>. Abort", self.databaseName);
        
        return NO;
    }
    
    self.requestCreateDoc.delegate = self;
    
    [self.networkManager executeRequest:self.requestCreateDoc];
    
    return YES;
}

- (void)releaseRequestCreateDoc
{
    if (self.requestCreateDoc)
    {
        self.requestCreateDoc.delegate = nil;
        self.requestCreateDoc = nil;
    }
}

- (BOOL)executeRequestDeleteDocWithData:(ICDModelDocument *)document
{
    if ([self isExecutingRequest])
    {
        ICDLogTrace(@"There is a request ongoing. Abort");
        
        return NO;
    }
    
    if (!self.networkManager)
    {
        ICDLogTrace(@"No network manager. Abort");
        
        return NO;
    }
    
    self.requestDeleteDoc = [[ICDRequestDeleteDocument alloc] initWithDatabaseName:self.databaseName
                                                                        documentId:document.documentId
                                                                       documentRev:document.documentRev];
    if (!self.requestDeleteDoc)
    {
        ICDLogWarning(@"Request not created with database name <%@> and document <%@>. Abort", self.databaseName, document);
        
        return NO;
    }
    
    self.requestDeleteDoc.delegate = self;
    
    [self.networkManager executeRequest:self.requestDeleteDoc];
    
    return YES;
}

- (void)releaseRequestDeleteDoc
{
    if (self.requestDeleteDoc)
    {
        self.requestDeleteDoc.delegate = nil;
        self.requestDeleteDoc = nil;
    }
}

- (BOOL)isExecutingRequest
{
    return (self.requestAllDocs || self.requestCreateDoc || self.requestDeleteDoc);
}

- (void)prepareForSegueDocumentVC:(ICDDocumentViewController *)documentVC
                         withCell:(UITableViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    ICDModelDocument *document = (ICDModelDocument *)self.allDocuments[indexPath.row];
    
    documentVC.delegate = self;
    [documentVC useNetworkManager:self.networkManager
                     databaseName:self.databaseName
                         document:document];
}

@end
