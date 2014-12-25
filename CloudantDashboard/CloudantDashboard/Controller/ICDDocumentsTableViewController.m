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

#import "ICDModelDocument.h"

#import "ICDLog.h"



NSString * const kICDDocumentsTVCCellID = @"documentCell";



@interface ICDDocumentsTableViewController () <ICDRequestAllDocumentsDelegate>

@property (strong, nonatomic) ICDNetworkManager *networkManager;

@property (strong, nonatomic) ICDRequestAllDocuments *requestAllDocs;

@property (strong, nonatomic) NSString *databaseName;

@property (strong, nonatomic) NSArray *allDocuments;

@end



@implementation ICDDocumentsTableViewController

#pragma mark - Init object
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        _allDocuments = @[];
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


#pragma mark - ICDRequestAllDocumentsForADatabaseDelegate methods
- (void)requestAllDocuments:(id<ICDRequestProtocol>)request didGetDocuments:(NSArray *)documents
{
    if (request != self.requestAllDocs)
    {
        ICDLogDebug(@"Received documents from unexpected request. Ignore");
        
        return;
    }
    
    [self releaseRequestAllDocs];
    
    self.allDocuments = documents;
    
    if ([self isViewLoaded])
    {
        [self.refreshControl endRefreshing];
        [self.tableView reloadData];
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


#pragma mark - Public methods
- (void)useNetworkManager:(ICDNetworkManager *)networkManager
             databaseName:(NSString *)databaseName
{
    self.networkManager = networkManager;
    self.databaseName = databaseName;
    
    [self releaseRequestAllDocs];
    
    [self executeRequestAllDocs];
}


#pragma mark - Private methods
- (void)customizeUI
{
    [self addRefreshControl];
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

- (BOOL)isExecutingRequest
{
    return (self.requestAllDocs != nil);
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
