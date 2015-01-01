//
//  ICDRequestProtocol.h
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 22/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import <Foundation/Foundation.h>



typedef void (^ICDRequestProtocolCompletionHandlerBlockType)(void);



@protocol ICDRequestProtocol <NSObject>

- (void)asynExecuteRequestWithObjectManager:(id)objectManager
                          completionHandler:(ICDRequestProtocolCompletionHandlerBlockType)completionHandler;

@end
