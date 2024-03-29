//
//  ICDControllerDesignDocViewsData.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 20/01/2015.
//  Copyright (c) 2015 Enrique de la Torre. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file
//  except in compliance with the License. You may obtain a copy of the License at
//    http://www.apache.org/licenses/LICENSE-2.0
//  Unless required by applicable law or agreed to in writing, software distributed under the
//  License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
//  either express or implied. See the License for the specific language governing permissions
//  and limitations under the License.
//

#import "ICDControllerDesignDocViewsData.h"

#import "ICDControllerDesignDocViewsCellCreatorShowDocuments.h"

#import "ICDNetworkManagerFactory.h"

#import "ICDRequestDesignDoc.h"

#import "ICDModelDesignDocument.h"
#import "ICDModelDesignDocumentView.h"

#import "ICDLog.h"



@interface ICDControllerDesignDocViewsData () <ICDRequestDesignDocDelegate>

@property (strong, nonatomic, readonly) NSString *databaseNameOrNil;
@property (strong, nonatomic, readonly) NSString *designDocIdOrNil;
@property (strong, nonatomic, readonly) id<ICDNetworkManagerProtocol> networkManager;

@property (assign, nonatomic) BOOL isRefreshingCellCreators;

@property (strong, nonatomic) NSMutableArray *allCellCreators;

@end



@implementation ICDControllerDesignDocViewsData

#pragma mark - Init object
- (id)init
{
    return [self initWithNetworkManager:nil databaseName:nil designDocId:nil];
}

- (id)initWithNetworkManager:(id<ICDNetworkManagerProtocol>)networkManagerOrNil
                databaseName:(NSString *)databaseNameOrNil
                 designDocId:(NSString *)designDocIdOrNil
{
    self = [super init];
    if (self)
    {
        _networkManager = (networkManagerOrNil ? networkManagerOrNil : [ICDNetworkManagerFactory networkManager]);
        _databaseNameOrNil = databaseNameOrNil;
        _designDocIdOrNil = designDocIdOrNil;
        
        _isRefreshingCellCreators = NO;
        
        _allCellCreators = [NSMutableArray array];
    }
    
    return self;
}


#pragma mark - ICDRequestDesignDocDelegate methods
- (void)requestDesignDoc:(id<ICDRequestProtocol>)request didGetDesignDoc:(ICDModelDesignDocument *)designDoc
{
    self.isRefreshingCellCreators = NO;
    
    // Update data
    BOOL isASecondaryIndex = [designDoc isASecondaryIndex];
    
    self.allCellCreators = [NSMutableArray arrayWithCapacity:[designDoc.views count]];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:ICDMODELDESIGNDOCUMENTVIEW_PROPERTY_KEY_VIEWNAME ascending:YES];
    NSArray *sortedViews = [designDoc.views sortedArrayUsingDescriptors:@[sortDescriptor]];
    
    ICDControllerDesignDocViewsCellCreatorShowDocuments *cellCreator = nil;
    for (ICDModelDesignDocumentView *oneView in sortedViews)
    {
        cellCreator = [[ICDControllerDesignDocViewsCellCreatorShowDocuments alloc] initWithNetworkManager:self.networkManager
                                                                                             databaseName:self.databaseNameOrNil
                                                                                              designDocId:self.designDocIdOrNil
                                                                                                 viewname:oneView.viewname
                                                                                           allowSelection:isASecondaryIndex];
        
        [self.allCellCreators addObject:cellCreator];
    }
    
    // Notify
    if (self.delegate)
    {
        [self.delegate icdControllerDesignDocViewsData:self didRefreshCellCreatorsWithResult:YES];
    }
}

- (void)requestDesignDoc:(id<ICDRequestProtocol>)request didFailWithError:(NSError *)error
{
    ICDLogError(@"Error: %@", error);
    
    self.isRefreshingCellCreators = NO;
    
    // Notify
    if (self.delegate)
    {
        [self.delegate icdControllerDesignDocViewsData:self didRefreshCellCreatorsWithResult:NO];
    }
}


#pragma mark - Public methods
- (NSInteger)numberOfCellCreators
{
    return [self.allCellCreators count];
}

- (id<ICDControllerDesignDocViewsCellCreatorProtocol>)cellCreatorAtIndex:(NSUInteger)index
{
    return (id<ICDControllerDesignDocViewsCellCreatorProtocol>)self.allCellCreators[index];
}

- (BOOL)asyncRefreshCellCreators
{
    self.isRefreshingCellCreators = [self executeRequestDesignDoc];
    if (self.isRefreshingCellCreators && self.delegate)
    {
        [self.delegate icdControllerDesignDocViewsDataWillRefreshCellCreators:self];
    }
    
    return self.isRefreshingCellCreators;
}


#pragma mark - Private methods
- (BOOL)executeRequestDesignDoc
{
    ICDRequestDesignDoc *requestDesignDoc = [[ICDRequestDesignDoc alloc] initWithDatabaseName:self.databaseNameOrNil
                                                                                  designDocId:self.designDocIdOrNil];
    if (!requestDesignDoc)
    {
        ICDLogWarning(@"Request not created with database name <%@> for id <%@>. Abort",
                      self.databaseNameOrNil, self.designDocIdOrNil);
        
        return NO;
    }
    
    requestDesignDoc.delegate = self;
    
    return [self.networkManager asyncExecuteRequest:requestDesignDoc];
}

@end
