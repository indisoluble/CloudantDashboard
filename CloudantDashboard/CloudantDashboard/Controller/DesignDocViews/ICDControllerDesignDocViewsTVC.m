//
//  ICDControllerDesignDocViewsTVC.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 20/01/2015.
//  Copyright (c) 2015 Enrique de la Torre. All rights reserved.
//

#import "ICDControllerDesignDocViewsTVC.h"

#import "ICDControllerDocumentsTVC.h"

#import "ICDControllerDesignDocViewsData.h"
#import "ICDControllerDocumentsDataDocsInDesignDocView.h"

#import "UITableViewController+RefreshControlHelper.h"



NSString * const kICDControllerDesignDocViewsTVCCellID = @"designDocViewCell";



@interface ICDControllerDesignDocViewsTVC () <ICDControllerDesignDocViewsDataDelegate>

@property (strong, nonatomic, readonly) ICDControllerDesignDocViewsData *data;

@end



@implementation ICDControllerDesignDocViewsTVC

#pragma mark - Init object
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        _data = [[ICDControllerDesignDocViewsData alloc] init];
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
    
    if (self.data.isRefreshingDesignDocViews)
    {
        [self forceShowRefreshControlAnimation];
    }
}


#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]] &&
        [segue.destinationViewController isKindOfClass:[ICDControllerDocumentsTVC class]])
    {
        [self prepareForSegueDocumentsTVC:segue.destinationViewController withCell:sender];
    }
}


#pragma mark - UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.data numberOfDesignDocViews];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ICDModelDesignDocumentView *designDocView = [self.data designDocViewAtIndex:indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kICDControllerDesignDocViewsTVCCellID
                                                            forIndexPath:indexPath];
    cell.textLabel.text = designDocView.viewname;
    
    return cell;
}


#pragma mark - ICDControllerDesignDocViewsDataDelegate methods
- (void)icdControllerDesignDocViewsDataWillRefreshDesignDocViews:(ICDControllerDesignDocViewsData *)data
{
    if ([self isViewLoaded])
    {
        [self forceShowRefreshControlAnimation];
    }
}

- (void)icdControllerDesignDocViewsData:(ICDControllerDesignDocViewsData *)data
     didRefreshDesignDocViewsWithResult:(BOOL)success
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
             databaseName:(NSString *)databaseName
              designDocId:(NSString *)designDocId
{
    if (designDocId)
    {
        self.title = designDocId;
    }
    
    [self recreateDataWithDatabaseName:databaseName designDocId:designDocId networkManager:networkManager];
    
    if ([self isViewLoaded])
    {
        [self.tableView reloadData];
        
        [self.refreshControl endRefreshing];
    }
    
    [self.data asyncRefreshDesignDocViews];
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
    if (![self.data asyncRefreshDesignDocViews])
    {
        [self.refreshControl endRefreshing];
    }
}

- (void)prepareForSegueDocumentsTVC:(ICDControllerDocumentsTVC *)documentsTVC
                           withCell:(UITableViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    ICDModelDesignDocumentView *designDocView = [self.data designDocViewAtIndex:indexPath.row];
    
    NSString *databaseOrNil = self.data.databaseNameOrNil;
    NSString *docIdOrNil = self.data.designDocIdOrNil;
    NSString *viewnameOrNil = designDocView.viewname;
    id<ICDNetworkManagerProtocol> manager = self.data.networkManager;
    ICDControllerDocumentsDataDocsInDesignDocView *viewData = [[ICDControllerDocumentsDataDocsInDesignDocView alloc] initWithDatabaseName:databaseOrNil
                                                                                                                              designDocId:docIdOrNil
                                                                                                                                 viewname:viewnameOrNil
                                                                                                                           networkManager:manager];
    
    documentsTVC.title = designDocView.viewname;
    [documentsTVC useData:viewData];
}

- (void)recreateDataWithDatabaseName:(NSString *)databaseName
                         designDocId:(NSString *)designDocId
                      networkManager:(id<ICDNetworkManagerProtocol>)networkManager
{
    [self releaseData];
    
    _data = [[ICDControllerDesignDocViewsData alloc] initWithNetworkManager:networkManager
                                                               databaseName:databaseName
                                                                designDocId:designDocId];
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
