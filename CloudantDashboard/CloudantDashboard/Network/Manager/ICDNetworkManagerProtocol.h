//
//  ICDNetworkManagerProtocol.h
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 03/01/2015.
//  Copyright (c) 2015 Enrique de la Torre. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ICDRequestProtocol.h"



@protocol ICDNetworkManagerProtocol <NSObject>

- (BOOL)isAuthorized;

- (BOOL)asyncExecuteRequest:(id<ICDRequestProtocol>)request;

@end
