//
//  ICDNetworkManagerDummy.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 03/01/2015.
//  Copyright (c) 2015 Enrique de la Torre. All rights reserved.
//

#import "ICDNetworkManagerDummy.h"



@interface ICDNetworkManagerDummy ()

@end



@implementation ICDNetworkManagerDummy

#pragma mark - ICDNetworkManagerProtocol methods
- (BOOL)isAuthorized
{
    return NO;
}

- (BOOL)asyncExecuteRequest:(id<ICDRequestProtocol>)request
{
    return NO;
}

@end
