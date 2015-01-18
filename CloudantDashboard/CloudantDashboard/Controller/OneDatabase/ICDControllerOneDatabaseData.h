//
//  ICDControllerOneDatabaseData.h
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 18/01/2015.
//  Copyright (c) 2015 Enrique de la Torre. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ICDNetworkManagerProtocol.h"
#import "ICDControllerOneDatabaseOptionProtocol.h"



@interface ICDControllerOneDatabaseData : NSObject

- (id)initWithDatabaseName:(NSString *)databaseNameOrNil
            networkManager:(id<ICDNetworkManagerProtocol>)networkManagerOrNil;

- (NSInteger)numberOfOptions;
- (id<ICDControllerOneDatabaseOptionProtocol>)optionAtIndex:(NSUInteger)index;

@end
