//
//  ICDControllerDesignDocViewsTVC.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 20/01/2015.
//  Copyright (c) 2015 Enrique de la Torre. All rights reserved.
//

#import "ICDControllerDesignDocViewsTVC.h"

#import "ICDControllerDesignDocViewsData.h"

#import "UITableViewController+RefreshControlHelper.h"



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
    
    if (self.data.isRefreshingCellCreators)
    {
        [self forceShowRefreshControlAnimation];
    }
}


#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)sender];
        id<ICDControllerDesignDocViewsCellCreatorProtocol> cellCreator = [self.data cellCreatorAtIndex:indexPath.row];
        
        [cellCreator configureViewController:segue.destinationViewController];
    }
}


#pragma mark - UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.data numberOfCellCreators];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<ICDControllerDesignDocViewsCellCreatorProtocol> cellCreator = [self.data cellCreatorAtIndex:indexPath.row];
    
    return [cellCreator cellForTableView:tableView atIndexPath:indexPath];
}


#pragma mark - UITableViewDelegate methods
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    id<ICDControllerDesignDocViewsCellCreatorProtocol> cellCreator = [self.data cellCreatorAtIndex:indexPath.row];
    
    return ([cellCreator canSelectCell] ? indexPath : nil);
}


#pragma mark - ICDControllerDesignDocViewsDataDelegate methods
- (void)icdControllerDesignDocViewsDataWillRefreshCellCreators:(ICDControllerDesignDocViewsData *)data
{
    if ([self isViewLoaded])
    {
        [self forceShowRefreshControlAnimation];
    }
}

- (void)icdControllerDesignDocViewsData:(ICDControllerDesignDocViewsData *)data
       didRefreshCellCreatorsWithResult:(BOOL)success
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
    
    [self.data asyncRefreshCellCreators];
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
    if (![self.data asyncRefreshCellCreators])
    {
        [self.refreshControl endRefreshing];
    }
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
