//
//  ICDControllerDocumentsTVC.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 23/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file
//  except in compliance with the License. You may obtain a copy of the License at
//    http://www.apache.org/licenses/LICENSE-2.0
//  Unless required by applicable law or agreed to in writing, software distributed under the
//  License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
//  either express or implied. See the License for the specific language governing permissions
//  and limitations under the License.
//

#import "ICDControllerDocumentsTVC.h"

#import "ICDControllerOneDocumentVC.h"

#import "ICDControllerDocumentsDataDummy.h"

#import "NSIndexPath+IndexSetHelper.h"
#import "NSDictionary+CloudantSpecialKeys.h"
#import "UITableViewController+RefreshControlHelper.h"



NSString * const kICDControllerDocumentsTVCCellID = @"documentCell";



@interface ICDControllerDocumentsTVC () <ICDControllerOneDocumentVCDelegate, ICDControllerDocumentsDataDelegate>

@property (strong, nonatomic, readonly) id<ICDControllerDocumentsDataProtocol> data;

@property (assign, nonatomic) BOOL isViewVisible;

@end



@implementation ICDControllerDocumentsTVC

#pragma mark - Init object
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        _data = [[ICDControllerDocumentsDataDummy alloc] init];
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
    
    [self updateRightBarButtonItemWithData:self.data];
    
    [self addRefreshControl];
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
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kICDControllerDocumentsTVCCellID
                                                            forIndexPath:indexPath];
    cell.textLabel.text = document.documentId;
    cell.detailTextLabel.text = document.documentRev;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.data respondsToSelector:@selector(asyncDeleteDocAtIndex:)];
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
    
    if ([self.data respondsToSelector:@selector(asyncBulkDocsWithData:numberOfCopies:)])
    {
        [self.data asyncBulkDocsWithData:[data dictionaryWithoutCloudantSpecialKeys] numberOfCopies:numberOfCopies];
    }
}


#pragma mark - ICDControllerDocumentsDataDelegate methods
- (void)icdControllerDocumentsDataWillRefreshDocs:(id<ICDControllerDocumentsDataProtocol>)data
{
    if ([self isViewLoaded])
    {
        [self forceShowRefreshControlAnimation];
    }
}

- (void)icdControllerDocumentsData:(id<ICDControllerDocumentsDataProtocol>)data
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

- (void)icdControllerDocumentsData:(id<ICDControllerDocumentsDataProtocol>)data
            didCreateDocsAtIndexes:(NSIndexSet *)indexes
{
    NSArray *indexPaths = [NSIndexPath indexPathsForRows:indexes inSection:0];
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    
    if (self.isViewVisible)
    {
        [self.tableView selectRowAtIndexPath:[indexPaths lastObject] animated:YES scrollPosition:UITableViewScrollPositionTop];
    }
}

- (void)icdControllerDocumentsData:(id<ICDControllerDocumentsDataProtocol>)data
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

- (void)icdControllerDocumentsData:(id<ICDControllerDocumentsDataProtocol>)data
               didDeleteDocAtIndex:(NSUInteger)index
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}


#pragma mark - Public methods
- (void)useData:(id<ICDControllerDocumentsDataProtocol>)data
{
    [self replaceData:data];
    
    if ([self isViewLoaded])
    {
        [self.tableView reloadData];
        
        [self.refreshControl endRefreshing];
        
        [self updateRightBarButtonItemWithData:self.data];
    }
    
    [self.data asyncRefreshDocs];
}


#pragma mark - Private methods
- (void)updateRightBarButtonItemWithData:(id<ICDControllerDocumentsDataProtocol>)thisData
{
    UIBarButtonItem *item = nil;
    
    if ([thisData respondsToSelector:@selector(asyncCreateDoc)])
    {
        item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                             target:thisData
                                                             action:@selector(asyncCreateDoc)];
    }
    
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

- (void)prepareForSegueDocumentVC:(ICDControllerOneDocumentVC *)documentVC
                         withCell:(UITableViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    ICDModelDocument *document = [self.data documentAtIndex:indexPath.row];
    
    documentVC.delegate = self;
    
#warning self.data could be replaced at any moment after this VC is initializated
    [documentVC useNetworkManager:self.data.networkManager
                     databaseName:self.data.databaseNameOrNil
                       documentId:document.documentId
                    allowCopyData:[self.data respondsToSelector:@selector(asyncBulkDocsWithData:numberOfCopies:)]];
}

- (void)replaceData:(id<ICDControllerDocumentsDataProtocol>)data
{
    [self releaseData];
    
    _data = (data ? data : [[ICDControllerDocumentsDataDummy alloc] init]);
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
