//
//  ICDControllerDesignDocViewsData.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 20/01/2015.
//  Copyright (c) 2015 Enrique de la Torre. All rights reserved.
//

#import "ICDControllerDesignDocViewsData.h"

#import "ICDNetworkManagerFactory.h"

#import "ICDRequestDesignDoc.h"

#import "ICDModelDesignDocument.h"

#import "ICDLog.h"



@interface ICDControllerDesignDocViewsData () <ICDRequestDesignDocDelegate>

@property (assign, nonatomic) BOOL isRefreshingDesignDocViews;

@property (assign, nonatomic) BOOL isASecondaryIndex;
@property (strong, nonatomic) NSArray *allDesignDocViews;

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
        
        _isRefreshingDesignDocViews = NO;
        
        _isASecondaryIndex = NO;
        _allDesignDocViews = @[];
    }
    
    return self;
}


#pragma mark - ICDRequestDesignDocDelegate methods
- (void)requestDesignDoc:(id<ICDRequestProtocol>)request didGetDesignDoc:(ICDModelDesignDocument *)designDoc
{
    self.isRefreshingDesignDocViews = NO;
    
    // Update data
    self.isASecondaryIndex = [designDoc isASecondaryIndex];
    self.allDesignDocViews = [designDoc.views allObjects];
    
    // Notify
    if (self.delegate)
    {
        [self.delegate icdControllerDesignDocViewsData:self didRefreshDesignDocViewsWithResult:YES];
    }
}

- (void)requestDesignDoc:(id<ICDRequestProtocol>)request didFailWithError:(NSError *)error
{
    ICDLogError(@"Error: %@", error);
    
    self.isRefreshingDesignDocViews = NO;
    
    // Notify
    if (self.delegate)
    {
        [self.delegate icdControllerDesignDocViewsData:self didRefreshDesignDocViewsWithResult:NO];
    }
}


#pragma mark - Public methods
- (NSInteger)numberOfDesignDocViews
{
    return [self.allDesignDocViews count];
}

- (ICDModelDesignDocumentView *)designDocViewAtIndex:(NSUInteger)index
{
    return (ICDModelDesignDocumentView *)self.allDesignDocViews[index];
}

- (BOOL)canSelectDesignDocViewAtIndex:(NSUInteger)index
{
    return self.isASecondaryIndex;
}

- (BOOL)asyncRefreshDesignDocViews
{
    self.isRefreshingDesignDocViews = [self executeRequestDesignDoc];
    if (self.isRefreshingDesignDocViews && self.delegate)
    {
        [self.delegate icdControllerDesignDocViewsDataWillRefreshDesignDocViews:self];
    }
    
    return self.isRefreshingDesignDocViews;
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
