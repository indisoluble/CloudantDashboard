//
//  ICDControllerDocumentsTVC.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 23/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import "ICDControllerDocumentsTVC.h"

#import "ICDControllerDocumentVC.h"

#import "ICDControllerDocumentsData.h"

#import "ICDCommonAnimationDuration.h"



NSString * const kICDDocumentsTVCCellID = @"documentCell";



@interface ICDControllerDocumentsTVC () <ICDControllerDocumentsDataDelegate>
{
    ICDControllerDocumentsData *_data;
}

@property (strong, nonatomic, readonly) ICDControllerDocumentsData *data;

@property (assign, nonatomic) BOOL isViewVisible;

@end



@implementation ICDControllerDocumentsTVC

#pragma mark - Synthesize properties
- (ICDControllerDocumentsData *)data
{
    if (!_data)
    {
        _data = [[ICDControllerDocumentsData alloc] init];
        _data.delegate = self;
    }
    
    return _data;
}


#pragma mark - Init object
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
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
    
    if ([self isMovingFromParentViewController])
    {
        [self.data reset];
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
               didCreateDocAtIndex:(NSUInteger)index
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
    if (self.isViewVisible)
    {
        [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
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
    
    [self.data asyncRefreshDocsWithNetworkManager:networkManager databaseName:databaseName];
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
                                                                          target:self.data
                                                                          action:@selector(asyncCreateDoc)];
    self.navigationItem.rightBarButtonItem = item;
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

- (void)prepareForSegueDocumentVC:(ICDControllerDocumentVC *)documentVC
                         withCell:(UITableViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    ICDModelDocument *document = [self.data documentAtIndex:indexPath.row];
    
    [documentVC useNetworkManager:self.data.networkManager
                     databaseName:self.data.databaseName
                         document:document];
}

@end