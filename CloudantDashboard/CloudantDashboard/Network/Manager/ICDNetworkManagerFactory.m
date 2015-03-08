//
//  ICDNetworkManagerFactory.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 03/01/2015.
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
