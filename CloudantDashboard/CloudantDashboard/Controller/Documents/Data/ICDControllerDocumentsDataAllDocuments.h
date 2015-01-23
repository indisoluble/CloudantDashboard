//
//  ICDControllerDocumentsDataAllDocuments.h
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 04/01/2015.
//  Copyright (c) 2015 Enrique de la Torre. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ICDControllerDocumentsDataProtocol.h"



@interface ICDControllerDocumentsDataAllDocuments : NSObject <ICDControllerDocumentsDataProtocol>

- (id)initWithDatabaseName:(NSString *)databaseNameOrNil
            networkManager:(id<ICDNetworkManagerProtocol>)networkManagerOrNil;

@end
