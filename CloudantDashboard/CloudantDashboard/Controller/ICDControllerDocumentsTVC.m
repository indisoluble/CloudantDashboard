//
//  ICDControllerDocumentsTVC.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 23/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import "ICDControllerDocumentsTVC.h"

#import "ICDControllerOneDocumentVC.h"

#import "ICDControllerDocumentsData.h"

#import "NSDictionary+CloudantSpecialKeys.h"
#import "NSIndexPath+IndexSetHelper.h"
#import "UITableViewController+RefreshControlHelper.h"



NSString * const kICDDocumentsTVCCellID = @"documentCell";



@interface ICDControllerDocumentsTVC () <ICDControllerOneDocumentVCDelegate, ICDControllerDocumentsDataDelegate>

@property (strong, nonatomic, readonly) ICDControllerDocumentsData *data;

@property (assign, nonatomic) BOOL isViewVisible;

@end



@implementation ICDControllerDocumentsTVC

#pragma mark - Init object
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        _data = [[ICDControllerDocumentsData alloc] init];
        _data.delegate = self;
        
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
    
    if (self.data.isRefreshingDocs)
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
        [segue.destinationViewController isKindOfClass:[ICDControllerOneDocumentVC class]])
    {
        [self prepareForSegueDocumentVC:segue.destinationViewController withCell:sender];
    }
}


#pragma mark - UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.data numberOfDocuments];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ICDModelDocument *document = [self.data documentAtIndex:indexPath.row];
    
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
    [self.data asyncDeleteDocAtIndex:indexPath.row];
}


#pragma mark - ICDControllerOneDocumentVCDelegate methods
- (void)icdControllerOneDocumentVC:(ICDControllerOneDocumentVC *)vc
                 didSelectCopyData:(NSDictionary *)data
                             times:(NSUInteger)numberOfCopies
{
    [vc.navigationController popToViewController:self animated:YES];
    
    [self.data asyncBulkDocsWithData:[data dictionaryWithoutCloudantSpecialKeys] numberOfCopies:numberOfCopies];
}


#pragma mark - ICDControllerDocumentsDataDelegate methods
- (void)icdControllerDocumentsDataWillRefreshDocs:(ICDControllerDocumentsData *)data
{
    if ([self isViewLoaded])
    {
        [self forceShowRefreshControlAnimation];
    }
}

- (void)icdControllerDocumentsData:(ICDControllerDocumentsData *)data
          didRefreshDocsWithResult:(BOOL)success
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

- (void)icdControllerDocumentsData:(ICDControllerDocumentsData *)data
            didCreateDocsAtIndexes:(NSIndexSet *)indexes
{
    NSArray *indexPaths = [NSIndexPath indexPathsForRows:indexes inSection:0];
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    
    if (self.isViewVisible)
    {
        [self.tableView selectRowAtIndexPath:[indexPaths lastObject] animated:YES scrollPosition:UITableViewScrollPositionTop];
    }
}

- (void)icdControllerDocumentsData:(ICDControllerDocumentsData *)data
               didUpdateDocAtIndex:(NSUInteger)index
{
    if ([self isViewLoaded])
    {
        NSIndexPath *indexPathForSelectedRow = [self.tableView indexPathForSelectedRow];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        
        if ([indexPath isEqual:indexPathForSelectedRow])
        {
            [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }        
    }
}

- (void)icdControllerDocumentsData:(ICDControllerDocumentsData *)data
               didDeleteDocAtIndex:(NSUInteger)index
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}


#pragma mark - Public methods
- (void)useNetworkManager:(id<ICDNetworkManagerProtocol>)networkManager
             databaseName:(NSString *)databaseName
{
    if (databaseName)
    {
        self.title = databaseName;
    }
    
    [self recreateDataWithDatabaseName:databaseName networkManager:networkManager];
    
    if ([self isViewLoaded])
    {
        [self.tableView reloadData];
        
        [self.refreshControl endRefreshing];
    }
    
    [self.data asyncRefreshDocs];
}


#pragma mark - Private methods
- (void)customizeUI
{
    [self addRightBarButtonItems];
    [self addRefreshControl];
}

- (void)addRightBarButtonItems
{
    self.navigationItem.rightBarButtonItems = @[[self addBarButtomItem]];
}

- (UIBarButtonItem *)addBarButtomItem
{
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                          target:self.data
                                                                          action:@selector(asyncCreateDoc)];
    
    return item;
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
    if (![self.data asyncRefreshDocs])
    {
        [self.refreshControl endRefreshing];
    }
}

- (void)prepareForSegueDocumentVC:(ICDControllerOneDocumentVC *)documentVC
                         withCell:(UITableViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    ICDModelDocument *document = [self.data documentAtIndex:indexPath.row];
    
    documentVC.delegate = self;
    [documentVC useNetworkManager:self.data.networkManager
                     databaseName:self.data.databaseNameOrNil
                         document:document];
}

- (void)recreateDataWithDatabaseName:(NSString *)databaseName
                      networkManager:(id<ICDNetworkManagerProtocol>)networkManager
{
    [self releaseData];
    
    _data = [[ICDControllerDocumentsData alloc] initWithDatabaseName:databaseName networkManager:networkManager];
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
