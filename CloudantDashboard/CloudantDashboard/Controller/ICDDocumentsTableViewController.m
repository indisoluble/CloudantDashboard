//
//  ICDDocumentsTableViewController.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 23/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import "ICDDocumentsTableViewController.h"

#import "ICDRequestAllDocuments.h"

#import "ICDModelDocument.h"

#import "ICDLog.h"



NSString * const kICDDocumentsTVCCellID = @"documentCell";



@interface ICDDocumentsTableViewController () <ICDRequestAllDocumentsDelegate>
{
    ICDRequestAllDocuments *_requestAllDocs;
}

@property (strong, nonatomic, readonly) ICDRequestAllDocuments *requestAllDocs;

@property (strong, nonatomic) NSArray *allDocuments;

@end



@implementation ICDDocumentsTableViewController

#pragma mark - Synthesize properties
- (void)setNetworkManager:(ICDNetworkManager *)networkManager
{
    _networkManager = networkManager;
    
    [self requestDocumentsForDatabase];
}

- (void)setDatabaseName:(NSString *)databaseName
{
    _databaseName = databaseName;
    
    if (_requestAllDocs)
    {
        _requestAllDocs.delegate = nil;
        _requestAllDocs = nil;
    }
    
    [self requestDocumentsForDatabase];
}

- (ICDRequestAllDocuments *)requestAllDocs
{
    if (!_requestAllDocs && self.databaseName)
    {
        _requestAllDocs = [[ICDRequestAllDocuments alloc] initWithDatabaseName:self.databaseName];
        _requestAllDocs.delegate = self;
    }
    
    return _requestAllDocs;
}


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
    
    self.allDocuments = documents;
    
    if ([self isViewLoaded])
    {
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
}


#pragma mark - Private methods
- (void)requestDocumentsForDatabase
{
    if (self.networkManager && self.requestAllDocs)
    {
        [self.networkManager executeRequest:self.requestAllDocs];
    }
}

@end
