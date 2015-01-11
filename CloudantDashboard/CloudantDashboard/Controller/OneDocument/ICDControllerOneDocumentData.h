//
//  ICDControllerOneDocumentData.h
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 07/01/2015.
//  Copyright (c) 2015 Enrique de la Torre. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ICDNetworkManagerProtocol.h"

#import "ICDModelDocument.h"



@protocol ICDControllerOneDocumentDataDelegate;



@interface ICDControllerOneDocumentData : NSObject

@property (strong, nonatomic, readonly) ICDModelDocument *documentOrNil;
@property (strong, nonatomic, readonly) NSDictionary *fullDocument;

@property (weak, nonatomic) id<ICDControllerOneDocumentDataDelegate> delegate;

- (id)initWithNetworkManager:(id<ICDNetworkManagerProtocol>)networkManagerOrNil
                databaseName:(NSString *)databaseNameOrNil
                    document:(ICDModelDocument *)documentOrNil;

- (BOOL)asyncGetFullDocument;
- (BOOL)asyncUpdateDocumentWithData:(NSDictionary *)data;

@end



@protocol ICDControllerOneDocumentDataDelegate <NSObject>

- (void)icdControllerOneDocumentData:(ICDControllerOneDocumentData *)data
             didGetFullDocWithResult:(BOOL)success;

- (void)icdControllerOneDocumentData:(ICDControllerOneDocumentData *)data
              didUpdateDocWithResult:(BOOL)success;

@end
