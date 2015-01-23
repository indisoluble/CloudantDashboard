//
//  ICDControllerDocumentsTVC.h
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 23/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ICDControllerDocumentsDataProtocol.h"



@interface ICDControllerDocumentsTVC : UITableViewController

- (void)useData:(id<ICDControllerDocumentsDataProtocol>)data;

@end
