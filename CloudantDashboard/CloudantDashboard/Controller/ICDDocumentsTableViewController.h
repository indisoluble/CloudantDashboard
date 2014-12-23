//
//  ICDDocumentsTableViewController.h
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 23/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ICDNetworkManager.h"



@interface ICDDocumentsTableViewController : UITableViewController

@property (strong, nonatomic) ICDNetworkManager *networkManager;

@property (strong, nonatomic) NSString *databaseName;

@end
