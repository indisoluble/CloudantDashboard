//
//  ICDRequestProtocol.h
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 22/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import <Foundation/Foundation.h>



@protocol ICDRequestProtocol <NSObject>

- (void)executeRequestWithObjectManager:(id)objectManager;

+ (void)configureObjectManager:(id)objectManager;

@end