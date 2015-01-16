//
//  ICDControllerDesignDocsTVC.h
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 16/01/2015.
//  Copyright (c) 2015 Enrique de la Torre. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ICDNetworkManagerProtocol.h"



@interface ICDControllerDesignDocsTVC : UITableViewController

- (void)useNetworkManager:(id<ICDNetworkManagerProtocol>)networkManager
             databaseName:(NSString *)databaseName;

@end
