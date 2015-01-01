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

@property (assign, nonatomic) BOOL isExecutingRequest;

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
            
            _isExecutingRequest = NO;
        }
    }
    
    return self;
}


#pragma mark - Public methods
- (BOOL)asyncExecuteRequest:(id<ICDRequestProtocol>)request
{
    if (self.isExecutingRequest)
    {
        return NO;
    }
    
    self.isExecutingRequest = YES;
    
    __weak ICDNetworkManager *wealSelf = self;
    [request asynExecuteRequestWithObjectManager:self.objectManager completionHandler:^{
         __strong ICDNetworkManager *strongSelf = wealSelf;
         if (strongSelf)
         {
             strongSelf.isExecutingRequest = NO;
         }
     }];
    
    return YES;
}

@end
