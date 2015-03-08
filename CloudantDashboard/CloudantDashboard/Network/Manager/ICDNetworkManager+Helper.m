//
//  ICDNetworkManager+Helper.m
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

#import <RestKit/RestKit.h>

#import "ICDNetworkManager+Helper.h"



#define ICDNETWORKMANAGER_BASEURL_FORMAT    @"https://%@.cloudant.com"

#define ICDNETWORKMANAGER_HEADER_CONTENTTYPE_KEY    @"Content-type"
#define ICDNETWORKMANAGER_HEADER_CONTENTTYPE_VALUE  @"application/json"
#define ICDNETWORKMANAGER_HEADER_ACCEPT_KEY         @"Accept"
#define ICDNETWORKMANAGER_HEADER_ACCEPT_VALUE       ICDNETWORKMANAGER_HEADER_CONTENTTYPE_VALUE



@implementation ICDNetworkManager (Helper)

#pragma mark - Public class methods
+ (instancetype)networkManagerWithUsername:(NSString *)username
                                  password:(NSString *)password
{    
    NSString *baseURLStr = [NSString stringWithFormat:ICDNETWORKMANAGER_BASEURL_FORMAT, username];
    
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:baseURLStr]];
    [client setAuthorizationHeaderWithUsername:username password:password];
    [client setDefaultHeader:ICDNETWORKMANAGER_HEADER_CONTENTTYPE_KEY
                       value:ICDNETWORKMANAGER_HEADER_CONTENTTYPE_VALUE];
    [client setDefaultHeader:ICDNETWORKMANAGER_HEADER_ACCEPT_KEY
                       value:ICDNETWORKMANAGER_HEADER_ACCEPT_VALUE];
    client.parameterEncoding = AFJSONParameterEncoding;
    
    RKObjectManager *objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
    
    return [[ICDNetworkManager alloc] initWithObjectManager:objectManager];
}

@end
