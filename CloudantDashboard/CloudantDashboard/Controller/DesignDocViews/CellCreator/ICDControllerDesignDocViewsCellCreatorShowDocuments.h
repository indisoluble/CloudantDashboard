//
//  ICDControllerDesignDocViewsCellCreatorShowDocuments.h
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 25/01/2015.
//  Copyright (c) 2015 Enrique de la Torre. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ICDControllerDesignDocViewsCellCreatorProtocol.h"

#import "ICDNetworkManagerProtocol.h"



@interface ICDControllerDesignDocViewsCellCreatorShowDocuments : NSObject <ICDControllerDesignDocViewsCellCreatorProtocol>

- (id)initWithNetworkManager:(id<ICDNetworkManagerProtocol>)networkManagerOrNil
                databaseName:(NSString *)databaseNameOrNil
                 designDocId:(NSString *)designDocIdOrNil
                    viewname:(NSString *)viewnameOrNil
              allowSelection:(BOOL)allowSelection;

@end
