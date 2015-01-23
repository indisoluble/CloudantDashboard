//
//  ICDControllerOneDocumentVC.h
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 23/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ICDNetworkManagerProtocol.h"

#import "ICDModelDocument.h"



@protocol ICDControllerOneDocumentVCDelegate;



@interface ICDControllerOneDocumentVC : UIViewController

@property (weak, nonatomic) id<ICDControllerOneDocumentVCDelegate> delegate;

- (void)useNetworkManager:(id<ICDNetworkManagerProtocol>)networkManager
             databaseName:(NSString *)databaseName
                 document:(ICDModelDocument *)document
            allowCopyData:(BOOL)allowCopy;

@end



@protocol ICDControllerOneDocumentVCDelegate <NSObject>

- (void)icdControllerOneDocumentVC:(ICDControllerOneDocumentVC *)vc
                 didSelectCopyData:(NSDictionary *)data
                             times:(NSUInteger)numberOfCopies;

@end
