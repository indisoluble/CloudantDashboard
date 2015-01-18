//
//  ICDControllerOneDatabaseOptionDesignDoc.h
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 18/01/2015.
//  Copyright (c) 2015 Enrique de la Torre. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ICDModelDocument.h"

#import "ICDControllerOneDatabaseOptionProtocol.h"
#import "ICDNetworkManagerProtocol.h"



@interface ICDControllerOneDatabaseOptionDesignDoc : NSObject <ICDControllerOneDatabaseOptionProtocol>

- (id)initWithDesignDoc:(ICDModelDocument *)designDoc
           databaseName:(NSString *)databaseNameOrNil
         networkManager:(id<ICDNetworkManagerProtocol>)networkManagerOrNil;

+ (instancetype)optionWithDesignDoc:(ICDModelDocument *)designDoc
                       databaseName:(NSString *)databaseNameOrNil
                     networkManager:(id<ICDNetworkManagerProtocol>)networkManagerOrNil;

@end
