//
//  ICDControllerDocumentsDataDummy.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 23/01/2015.
//  Copyright (c) 2015 Enrique de la Torre. All rights reserved.
//

#import "ICDControllerDocumentsDataDummy.h"

#import "ICDNetworkManagerFactory.h"



@interface ICDControllerDocumentsDataDummy ()

@end



@implementation ICDControllerDocumentsDataDummy

#pragma mark - Synthesize properties
@synthesize databaseNameOrNil = _databaseNameOrNil;
@synthesize networkManager = _networkManager;

@synthesize isRefreshingDocs = _isRefreshingDocs;

@synthesize delegate = _delegate;


#pragma mark - Init object
- (id)init
{
    self = [super init];
    if (self)
    {
        _databaseNameOrNil = nil;
        _networkManager = [ICDNetworkManagerFactory networkManager];
        
        _isRefreshingDocs = NO;
    }
    
    return self;
}


#pragma mark - ICDControllerDocumentsDataProtocol methods
- (NSInteger)numberOfDocuments
{
    return 0;
}

- (ICDModelDocument *)documentAtIndex:(NSUInteger)index
{
    return nil;
}

- (BOOL)asyncRefreshDocs
{
    return NO;
}

@end
