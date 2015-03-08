//
//  ICDNetworkManager.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 22/12/2014.
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

#import "ICDNetworkManager.h"

#import "ICDLog.h"



@interface ICDNetworkManager ()

@property (strong, nonatomic) id objectManager;

@property (strong, nonatomic) NSMutableArray *requestStack;
@property (assign, nonatomic) NSUInteger requestCounter;

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
            
            _requestStack = [NSMutableArray array];
            _requestCounter = 0;
        }
    }
    
    return self;
}


#pragma mark - ICDNetworkManagerProtocol methods
- (BOOL)isAuthorized
{
    return YES;
}

- (BOOL)asyncExecuteRequest:(id<ICDRequestProtocol>)request
{
    if ([self isStackEmpty])
    {
        [self addRequest:request];
        
        [self asyncExecuteFirstRequest];
    }
    else
    {
        [self addRequest:request];
    }
    
    return YES;
}


#pragma mark - Private methods
- (void)asyncExecuteFirstRequest
{
    id<ICDRequestProtocol> firstRequest = [self firstRequest];
    if (!firstRequest)
    {
        ICDLogTrace(@"No more requests");
        
        return;
    }
    
    __weak ICDNetworkManager *wealSelf = self;
    [firstRequest asynExecuteRequestWithObjectManager:self.objectManager completionHandler:^{
        __strong ICDNetworkManager *strongSelf = wealSelf;
        if (strongSelf)
        {
            ICDLogTrace(@"%lu requests completed", ++strongSelf.requestCounter);
            
            [strongSelf removeFirstRequest];
            
            [strongSelf asyncExecuteFirstRequest];
        }
    }];
}

- (BOOL)isStackEmpty
{
    return ([self.requestStack count] == 0);
}

- (void)addRequest:(id<ICDRequestProtocol>)request
{
    [self.requestStack addObject:request];
}

- (id<ICDRequestProtocol>)firstRequest
{
    return [self.requestStack firstObject];
}

- (void)removeFirstRequest
{
    if (![self isStackEmpty])
    {
        [self.requestStack removeObjectAtIndex:0];
    }
}

@end
