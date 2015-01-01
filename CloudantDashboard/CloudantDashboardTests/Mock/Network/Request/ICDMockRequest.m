//
//  ICDMockRequest.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 22/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import "ICDMockRequest.h"



@interface ICDMockRequest ()

@end



@implementation ICDMockRequest

#pragma mark - Init object
- (id)init
{
    self = [super init];
    if (self)
    {
        _executeRequestCounter = 0;
    }
    
    return self;
}


#pragma mark - ICDRequestProtocol methods
- (void)asynExecuteRequestWithObjectManager:(id)objectManager
                          completionHandler:(ICDRequestProtocolCompletionHandlerBlockType)completionHandler
{
    _executeRequestCounter++;
    
    if (completionHandler && self.doExecuteCompletionHandler)
    {
        completionHandler();
    }
}

@end
