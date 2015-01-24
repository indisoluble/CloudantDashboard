//
//  ICDControllerDocumentsDataDocsInDesignDocView.h
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 24/01/2015.
//  Copyright (c) 2015 Enrique de la Torre. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ICDControllerDocumentsDataProtocol.h"



@interface ICDControllerDocumentsDataDocsInDesignDocView : NSObject <ICDControllerDocumentsDataProtocol>

- (id)initWithDatabaseName:(NSString *)databaseNameOrNil
               designDocId:(NSString *)designDocIdOrNil
                  viewname:(NSString *)viewnameOrNil
            networkManager:(id<ICDNetworkManagerProtocol>)networkManagerOrNil;

@end
