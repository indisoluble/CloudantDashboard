//
//  ICDControllerOneDatabaseOptionProtocol.h
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 11/01/2015.
//  Copyright (c) 2015 Enrique de la Torre. All rights reserved.
//

#import <UIKit/UIKit.h>



@protocol ICDControllerOneDatabaseOptionProtocol <NSObject>

- (UITableViewCell *)cellForTableView:(UITableView *)tableView
                          atIndexPath:(NSIndexPath *)indexPath;

- (NSString *)segueIdentifier;
- (void)configureViewController:(UIViewController *)viewController;

@end
