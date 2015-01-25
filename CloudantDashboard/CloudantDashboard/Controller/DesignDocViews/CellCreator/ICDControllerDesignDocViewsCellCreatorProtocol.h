//
//  ICDControllerDesignDocViewsCellCreatorProtocol.h
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 25/01/2015.
//  Copyright (c) 2015 Enrique de la Torre. All rights reserved.
//

#import <UIKit/UIKit.h>



@protocol ICDControllerDesignDocViewsCellCreatorProtocol <NSObject>

- (UITableViewCell *)cellForTableView:(UITableView *)tableView
                          atIndexPath:(NSIndexPath *)indexPath;

- (BOOL)canSelectCell;

- (void)configureViewController:(UIViewController *)viewController;

@end
