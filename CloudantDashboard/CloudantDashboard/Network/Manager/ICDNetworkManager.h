//
//  ICDNetworkManager.h
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 22/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ICDRequestProtocol.h"


@interface ICDNetworkManager : NSObject

- (id)initWithObjectManager:(id)objectManager;

- (BOOL)asyncExecuteRequest:(id<ICDRequestProtocol>)request;

@end
