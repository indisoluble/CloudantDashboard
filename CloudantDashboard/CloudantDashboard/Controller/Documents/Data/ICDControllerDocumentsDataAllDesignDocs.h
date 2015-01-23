//
//  ICDControllerDocumentsDataAllDesignDocs.h
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 17/01/2015.
//  Copyright (c) 2015 Enrique de la Torre. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ICDControllerDocumentsDataProtocol.h"



@interface ICDControllerDocumentsDataAllDesignDocs : NSObject <ICDControllerDocumentsDataProtocol>

- (id)initWithDatabaseName:(NSString *)databaseNameOrNil
            networkManager:(id<ICDNetworkManagerProtocol>)networkManagerOrNil;

@end
