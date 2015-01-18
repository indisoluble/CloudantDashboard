//
//  ICDControllerDesignDocsTVC.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 16/01/2015.
//  Copyright (c) 2015 Enrique de la Torre. All rights reserved.
//

#import "ICDControllerDesignDocsTVC.h"

#import "ICDControllerOneDocumentVC.h"

#import "ICDControllerDesignDocsData.h"

#import "UITableViewController+RefreshControlHelper.h"



NSString * const kICDControllerDesignDocsTVCCellID = @"designDocCell";



@interface ICDControllerDesignDocsTVC () <ICDControllerDesignDocsDataDelegate>

@property (strong, nonatomic, readonly) ICDControllerDesignDocsData *data;

@end



@implementation ICDControllerDesignDocsTVC

#pragma mark - Init object
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        _data = [[ICDControllerDesignDocsData alloc] init];
        _data.delegate = self;
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
    
    if (self.data.isRefreshingDesignDocs)
    {
        [self forceShowRefreshControlAnimation];
    }
}


#pragma mark - Navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]] &&
        [segue.destinationViewController isKindOfClass:[ICDControllerOneDocumentVC class]])
    {
        [self prepareForSegueDocumentVC:segue.destinationViewController withCell:sender];
    }
}


#pragma mark - UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.data numberOfDesignDocs];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ICDModelDocument *document = [self.data designDocAtIndex:indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kICDControllerDesignDocsTVCCellID
                                                            forIndexPath:indexPath];
    cell.textLabel.text = document.documentId;
    cell.detailTextLabel.text = document.documentRev;
    
    return cell;
}


#pragma mark - ICDControllerDesignDocsDataDelegate methods
- (void)icdControllerDesignDocsDataWillRefreshDesignDocs:(ICDControllerDesignDocsData *)data
{
    if ([self isViewLoaded])
    {
        [self forceShowRefreshControlAnimation];
    }
}

- (void)icdControllerDesignDocsData:(ICDControllerDesignDocsData *)data
     didRefreshDesignDocsWithResult:(BOOL)success
{
    if ([self isViewLoaded])
    {
        if (success)
        {
            [self.tableView reloadData];
        }
        
        [self.refreshControl endRefreshing];
    }
}


#pragma mark - Public methods
- (void)useNetworkManager:(id<ICDNetworkManagerProtocol>)networkManager
             databaseName:(NSString *)databaseName;
{
    [self recreateDataWithDatabaseName:databaseName networkManager:networkManager];
    
    if ([self isViewLoaded])
    {
        [self.tableView reloadData];
        
        [self.refreshControl endRefreshing];
    }
    
    [self.data asyncRefreshDesignDocs];
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
                       action:@selector(executeActionAfterPullingToRefresh)
             forControlEvents:UIControlEventValueChanged];
    
    self.refreshControl = refreshControl;
}

- (void)executeActionAfterPullingToRefresh
{
    if (![self.data asyncRefreshDesignDocs])
    {
        [self.refreshControl endRefreshing];
    }
}

- (void)prepareForSegueDocumentVC:(ICDControllerOneDocumentVC *)documentVC
                         withCell:(UITableViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    ICDModelDocument *designDoc = [self.data designDocAtIndex:indexPath.row];
    
    [documentVC useNetworkManager:self.data.networkManager
                     databaseName:self.data.databaseNameOrNil
                         document:designDoc];
}

- (void)recreateDataWithDatabaseName:(NSString *)databaseName
                      networkManager:(id<ICDNetworkManagerProtocol>)networkManager
{
    [self releaseData];
    
    _data = [[ICDControllerDesignDocsData alloc] initWithDatabaseName:databaseName networkManager:networkManager];
    _data.delegate = self;
}

- (void)releaseData
{
    if (_data)
    {
        _data.delegate = nil;
        _data = nil;
    }
}

@end
