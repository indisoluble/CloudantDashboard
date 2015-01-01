//
//  ICDDocumentViewController.h
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 23/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ICDNetworkManager.h"

#import "ICDModelDocument.h"



@interface ICDDocumentViewController : UIViewController

- (void)useNetworkManager:(ICDNetworkManager *)networkManager
             databaseName:(NSString *)databaseName
                 document:(ICDModelDocument *)document;
@end
