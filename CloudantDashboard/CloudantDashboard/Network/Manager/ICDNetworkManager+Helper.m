//
//  ICDNetworkManager+Helper.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 22/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import <RestKit/RestKit.h>

#import "ICDNetworkManager+Helper.h"

#import "ICDLog.h"



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
    if (!username || !password)
    {
        ICDLogError(@"Params not informed");
        
        return nil;
    }
    
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
