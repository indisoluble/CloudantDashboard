//
//  ICDControllerOneDatabaseOptionAllDocs.h
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 11/01/2015.
//  Copyright (c) 2015 Enrique de la Torre. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ICDControllerOneDatabaseOptionProtocol.h"
#import "ICDNetworkManagerProtocol.h"




@interface ICDControllerOneDatabaseOptionAllDocs : NSObject <ICDControllerOneDatabaseOptionProtocol>

- (id)initWithDatabaseName:(NSString *)databaseNameOrNil
            networkManager:(id<ICDNetworkManagerProtocol>)networkManagerOrNil;

+ (instancetype)optionWithDatabaseName:(NSString *)databaseNameOrNil
                        networkManager:(id<ICDNetworkManagerProtocol>)networkManagerOrNil;

@end
