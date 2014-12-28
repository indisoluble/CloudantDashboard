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
    ICDRequestDeleteDocumentDelegate>

@property (strong, nonatomic) ICDNetworkManager *networkManager;

@property (strong, nonatomic) ICDRequestAllDocuments *requestAllDocs;
@property (strong, nonatomic) ICDRequestCreateDocument *requestCreateDoc;
@property (strong, nonatomic) ICDRequestDeleteDocument *requestDeleteDoc;

@property (strong, nonatomic) NSString *databaseName;

@property (strong, nonatomic) NSMutableArray *allDocuments;

@end



@implementation ICDDocumentsTableViewController

#pragma mark - Init object
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        _allDocuments = [NSMutableArray array];
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
    
    [self customizeUI];
    
    if (self.requestAllDocs)
    {
        [self forceShowRefreshControlAnimation];
    }
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
    
    [self.allDocuments addObject:document];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:([self.allDocuments count] - 1) inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
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


#pragma mark - Public methods
- (void)useNetworkManager:(ICDNetworkManager *)networkManager
             databaseName:(NSString *)databaseName
{
    self.networkManager = networkManager;
    self.databaseName = databaseName;
    
    [self releaseRequestAllDocs];
    [self releaseRequestCreateDoc];
    [self releaseRequestDeleteDoc];
    
    [self executeRequestAllDocs];
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
    if (![self executeRequestAllDocs])
    {
        [self.refreshControl endRefreshing];
    }
}

- (void)forceShowRefreshControlAnimation
{
    [self.refreshControl beginRefreshing];
    self.tableView.contentOffset = CGPointMake(0, -self.refreshControl.frame.size.height);
}

- (BOOL)executeRequestAllDocs
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
    
    if ([self isViewLoaded])
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
    
    [documentVC useNetworkManager:self.networkManager
                     databaseName:self.databaseName
                       documentId:document.documentId];
}

@end
