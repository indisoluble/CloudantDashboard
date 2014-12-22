//
//  ICDMockRequest.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 22/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import "ICDMockRequest.h"



static NSUInteger icdMockRequestConfigurationCounter = 0;



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
- (void)executeRequestWithObjectManager:(id)objectManager
{
    _executeRequestCounter++;
}

+ (void)configureObjectManager:(id)objectManager
{
    [ICDMockRequest incConfigureCounter];
}


#pragma mark - Public class methods
+ (void)resetConfigureCounter
{
    icdMockRequestConfigurationCounter = 0;
}

+ (void)incConfigureCounter
{
    icdMockRequestConfigurationCounter++;
}

+ (NSUInteger)configureCounter
{
    return icdMockRequestConfigurationCounter;
}

@end
