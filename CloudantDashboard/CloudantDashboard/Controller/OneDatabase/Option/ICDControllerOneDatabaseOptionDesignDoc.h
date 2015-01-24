//
//  ICDControllerOneDatabaseOptionDesignDoc.h
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 18/01/2015.
//  Copyright (c) 2015 Enrique de la Torre. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ICDControllerOneDatabaseOptionProtocol.h"
#import "ICDNetworkManagerProtocol.h"



@interface ICDControllerOneDatabaseOptionDesignDoc : NSObject <ICDControllerOneDatabaseOptionProtocol>

- (id)initWithDesignDocId:(NSString *)designDocId
             databaseName:(NSString *)databaseNameOrNil
           networkManager:(id<ICDNetworkManagerProtocol>)networkManagerOrNil;

+ (instancetype)optionWithDesignDocId:(NSString *)designDocId
                         databaseName:(NSString *)databaseNameOrNil
                       networkManager:(id<ICDNetworkManagerProtocol>)networkManagerOrNil;

@end
