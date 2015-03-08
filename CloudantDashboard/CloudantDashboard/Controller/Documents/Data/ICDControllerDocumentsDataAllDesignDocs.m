//
//  ICDControllerDocumentsDataAllDesignDocs.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 17/01/2015.
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

#import "ICDControllerDocumentsDataAllDesignDocs.h"

#import "ICDNetworkManagerFactory.h"

#import "ICDRequestAllDocuments.h"
#import "ICDRequestAddRevisionNotification.h"

#import "ICDLog.h"



@interface ICDControllerDocumentsDataAllDesignDocs () <ICDRequestAllDocumentsDelegate>

@property (assign, nonatomic) BOOL isRefreshingDocs;

@property (strong, nonatomic) NSMutableArray *allDesignDocs;

@property (assign, nonatomic) BOOL didAddRevisionObserverAdded;

@end



@implementation ICDControllerDocumentsDataAllDesignDocs

#pragma mark - Synthesize properties
@synthesize databaseNameOrNil = _databaseNameOrNil;
@synthesize networkManager = _networkManager;

@synthesize delegate = _delegate;


#pragma mark - Init object
- (id)init
{
    return [self initWithDatabaseName:nil networkManager:nil];
}

- (id)initWithDatabaseName:(NSString *)databaseNameOrNil
            networkManager:(id<ICDNetworkManagerProtocol>)networkManagerOrNil
{
    self = [super init];
    if (self)
    {
        _databaseNameOrNil = databaseNameOrNil;
        _networkManager = (networkManagerOrNil ? networkManagerOrNil : [ICDNetworkManagerFactory networkManager]);
        
        _isRefreshingDocs = NO;
        
        _allDesignDocs = [NSMutableArray array];
        
        _didAddRevisionObserverAdded = NO;
    }
    
    return self;
}


#pragma mark - Memory management
- (void)dealloc
{
    [self removeObserverForDidAddRevisionNotification];
}


#pragma mark - ICDControllerDocumentsDataProtocol methods
- (NSInteger)numberOfDocuments
{
    return [self.allDesignDocs count];
}

- (ICDModelDocument *)documentAtIndex:(NSUInteger)index
{
    return (ICDModelDocument *)self.allDesignDocs[index];
}

- (BOOL)asyncRefreshDocs
{
    self.isRefreshingDocs = [self executeRequestAllDesignDocs];
    if (self.isRefreshingDocs && self.delegate)
    {
        [self.delegate icdControllerDocumentsDataWillRefreshDocs:self];
    }
    
    return self.isRefreshingDocs;
}


#pragma mark - ICDRequestAllDocumentsDelegate methods
- (void)requestAllDocuments:(id<ICDRequestProtocol>)request didGetDocuments:(NSArray *)documents
{
    self.isRefreshingDocs = NO;
    
    [self addObserverForDidAddRevisionNotification];
    
    // Update data
    self.allDesignDocs = [NSMutableArray arrayWithArray:documents];
    [self.allDesignDocs sortUsingSelector:@selector(compare:)];
    
    // Notify
    if (self.delegate)
    {
        [self.delegate icdControllerDocumentsData:self didRefreshDocsWithResult:YES];
    }
}

- (void)requestAllDocuments:(id<ICDRequestProtocol>)request didFailWithError:(NSError *)error
{
    ICDLogError(@"Error: %@", error);
    
    self.isRefreshingDocs = NO;
    
    // Notify
    if (self.delegate)
    {
        [self.delegate icdControllerDocumentsData:self didRefreshDocsWithResult:NO];
    }
}


#pragma mark - Private methods
- (BOOL)executeRequestAllDesignDocs
{
    ICDRequestAllDocumentsArguments *arguments = [ICDRequestAllDocumentsArguments allDesignDocs];
    ICDRequestAllDocuments *requestAllDocs = [[ICDRequestAllDocuments alloc] initWithDatabaseName:self.databaseNameOrNil
                                                                                        arguments:arguments];
    if (!requestAllDocs)
    {
        ICDLogWarning(@"Request not created with database name <%@>. Abort", self.databaseNameOrNil);
        
        return NO;
    }
    
    requestAllDocs.delegate = self;
    
    return [self.networkManager asyncExecuteRequest:requestAllDocs];
}

- (void)addObserverForDidAddRevisionNotification
{
    if (!self.didAddRevisionObserverAdded)
    {
        [[ICDRequestAddRevisionNotification sharedInstance] addDidAddRevisionNotificationObserver:self
                                                                                         selector:@selector(didReceiveDidAddRevisionNotification:)];
        
        self.didAddRevisionObserverAdded = YES;
    }
}

- (void)removeObserverForDidAddRevisionNotification
{
    if (self.didAddRevisionObserverAdded)
    {
        [[ICDRequestAddRevisionNotification sharedInstance] removeDidAddRevisionNotificationObserver:self];
        
        self.didAddRevisionObserverAdded = NO;
    }
}

- (void)didReceiveDidAddRevisionNotification:(NSNotification *)notification
{
    ICDLogDebug(@"didAddRevision Notification: %@", notification);
    
    // Validate
    NSString *dbName = notification.userInfo[kICDRequestAddRevisionNotificationDidAddRevisionUserInfoKeyDatabaseName];
    if (!self.databaseNameOrNil || ![self.databaseNameOrNil isEqualToString:dbName])
    {
        ICDLogDebug(@"Revision added to a document in another database. Ignore");
        
        return;
    }
    
    ICDModelDocument *revision = notification.userInfo[kICDRequestAddRevisionNotificationDidAddRevisionUserInfoKeyRevision];
    
    NSComparator comparator = ^NSComparisonResult(id obj1, id obj2)
    {
        return [[(ICDModelDocument *)obj1 documentId] compare:[(ICDModelDocument *)obj2 documentId]];
    };
    
    NSUInteger index = [self.allDesignDocs indexOfObject:revision
                                           inSortedRange:NSMakeRange(0, [self.allDesignDocs count])
                                                 options:kNilOptions
                                         usingComparator:comparator];
    if (index == NSNotFound)
    {
        ICDLogWarning(@"No document for this revision: %@", revision);
        
        return;
    }
    
    // Update data
    [self.allDesignDocs replaceObjectAtIndex:index withObject:revision];
    
    // Notify
    if (self.delegate)
    {
        [self.delegate icdControllerDocumentsData:self didUpdateDocAtIndex:index];
    }
}

@end
