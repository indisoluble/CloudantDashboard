//
//  ICDControllerOneDatabaseTVC.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 11/01/2015.
//  Copyright (c) 2015 Enrique de la Torre. All rights reserved.
//

#import "ICDControllerOneDatabaseTVC.h"

#import "ICDControllerOneDatabaseData.h"

#import "UITableViewController+RefreshControlHelper.h"



@interface ICDControllerOneDatabaseTVC () <ICDControllerOneDatabaseDataDelegate>

@property (strong, nonatomic, readonly) ICDControllerOneDatabaseData *data;

@end



@implementation ICDControllerOneDatabaseTVC

#pragma mark - Init object
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        _data = [[ICDControllerOneDatabaseData alloc] init];
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
    if ([sender conformsToProtocol:@protocol(ICDControllerOneDatabaseOptionProtocol)])
    {
        id<ICDControllerOneDatabaseOptionProtocol> option = (id<ICDControllerOneDatabaseOptionProtocol>)sender;
        UIViewController *vc = [segue destinationViewController];
        
        [option configureViewController:vc];
    }
}


#pragma mark - UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.data numberOfOptions];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<ICDControllerOneDatabaseOptionProtocol> oneOption = [self.data optionAtIndex:indexPath.row];
    
    return [oneOption cellForTableView:tableView atIndexPath:indexPath];
}


#pragma mark - UITableViewDelegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<ICDControllerOneDatabaseOptionProtocol> oneOption = [self.data optionAtIndex:indexPath.row];
    
    NSString *segueIdentifier = [oneOption segueIdentifier];
    if (segueIdentifier)
    {
        [self performSegueWithIdentifier:segueIdentifier sender:oneOption];
    }
}


#pragma mark - ICDControllerOneDatabaseDataDelegate methods
- (void)icdControllerOneDatabaseDataWillRefreshDesignDocs:(ICDControllerOneDatabaseData *)data
{
    if ([self isViewLoaded])
    {
        [self forceShowRefreshControlAnimation];
    }
}

- (void)icdControllerOneDatabaseData:(ICDControllerOneDatabaseData *)data
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
             databaseName:(NSString *)databaseName
{
    if (databaseName)
    {
        self.title = databaseName;
    }
    
    [self recreateDataWithNetworkManager:networkManager databaseName:databaseName];
    
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

- (void)recreateDataWithNetworkManager:(id<ICDNetworkManagerProtocol>)networkManager
                          databaseName:(NSString *)databaseName
{
    [self releaseData];
    
    _data = [[ICDControllerOneDatabaseData alloc] initWithDatabaseName:databaseName
                                                        networkManager:networkManager];
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
