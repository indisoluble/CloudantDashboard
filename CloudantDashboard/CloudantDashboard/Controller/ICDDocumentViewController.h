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



@protocol ICDDocumentViewControllerDelegate;



@interface ICDDocumentViewController : UIViewController

@property (weak, nonatomic) id<ICDDocumentViewControllerDelegate> delegate;

- (void)useNetworkManager:(ICDNetworkManager *)networkManager
             databaseName:(NSString *)databaseName
                 document:(ICDModelDocument *)document;
@end



@protocol ICDDocumentViewControllerDelegate <NSObject>

- (void)icdDocumentVC:(ICDDocumentViewController *)vc didAddRevision:(ICDModelDocument *)revision;

@end