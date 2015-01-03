//
//  ICDNetworkManagerFactory.h
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 03/01/2015.
//  Copyright (c) 2015 Enrique de la Torre. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ICDNetworkManagerProtocol.h"



@interface ICDNetworkManagerFactory : NSObject

+ (id<ICDNetworkManagerProtocol>)networkManager;

+ (id<ICDNetworkManagerProtocol>)networkManagerWithUsername:(NSString *)username
                                                   password:(NSString *)password;

@end
