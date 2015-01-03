//
//  ICDNetworkManagerFactory.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 03/01/2015.
//  Copyright (c) 2015 Enrique de la Torre. All rights reserved.
//

#import "ICDNetworkManagerFactory.h"

#import "ICDNetworkManagerDummy.h"
#import "ICDNetworkManager+Helper.h"

#import "ICDLog.h"



@interface ICDNetworkManagerFactory ()

@end



@implementation ICDNetworkManagerFactory

#pragma mark - Public class methods
+ (id<ICDNetworkManagerProtocol>)networkManager
{
    return [[ICDNetworkManagerDummy alloc] init];
}

+ (id<ICDNetworkManagerProtocol>)networkManagerWithUsername:(NSString *)username
                                                   password:(NSString *)password
{
    if (!username || !password)
    {
        return [ICDNetworkManagerFactory networkManager];
    }
    
    return [ICDNetworkManager networkManagerWithUsername:username password:password];
}

@end
