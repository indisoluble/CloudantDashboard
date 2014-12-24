//
//  ICDNetworkManager.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 22/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import "ICDNetworkManager.h"



@interface ICDNetworkManager ()

@property (strong, nonatomic) id objectManager;
@property (strong, nonatomic) NSMutableSet *configuredRequests;

@end



@implementation ICDNetworkManager

#pragma mark - Init object
- (id)init
{
    return [self initWithObjectManager:nil];
}

- (id)initWithObjectManager:(id)objectManager
{
    self = [super init];
    if (self)
    {
        if (!objectManager)
        {
            self = nil;
        }
        else
        {
            _objectManager = objectManager;
            _configuredRequests = [NSMutableSet set];
        }
    }
    
    return self;
}


#pragma mark - Public methods
- (void)executeRequest:(id<ICDRequestProtocol>)request
{
    [self configureManagerWithRequest:request];
    
    [request executeRequestWithObjectManager:self.objectManager];
}


#pragma mark - Private methods
- (void)configureManagerWithRequest:(id<ICDRequestProtocol>)request
{
    Class requestClass = [request class];
    if (![self.configuredRequests containsObject:requestClass])
    {
        [self.configuredRequests addObject:requestClass];
        
        [(Class<ICDRequestProtocol>)requestClass configureObjectManager:self.objectManager];
    }
}

@end