//
//  ICDMockRequest.h
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 22/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ICDRequestProtocol.h"



@interface ICDMockRequest : NSObject <ICDRequestProtocol>

@property (assign, nonatomic, readonly) NSUInteger executeRequestCounter;

@property (assign, nonatomic) BOOL doExecuteCompletionHandler;

@end
