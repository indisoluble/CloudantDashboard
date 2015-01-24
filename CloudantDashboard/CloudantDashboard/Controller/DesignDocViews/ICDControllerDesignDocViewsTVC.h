//
//  ICDControllerDesignDocViewsTVC.h
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 20/01/2015.
//  Copyright (c) 2015 Enrique de la Torre. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ICDNetworkManagerProtocol.h"



@interface ICDControllerDesignDocViewsTVC : UITableViewController

- (void)useNetworkManager:(id<ICDNetworkManagerProtocol>)networkManager
             databaseName:(NSString *)databaseName
              designDocId:(NSString *)designDocId;

@end
