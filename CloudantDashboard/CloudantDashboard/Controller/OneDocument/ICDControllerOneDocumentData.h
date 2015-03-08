//
//  ICDControllerOneDocumentData.h
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 07/01/2015.
//  Copyright (c) 2015 Enrique de la Torre. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file
//  except in compliance with the License. You may obtain a copy of the License at
//    http://www.apache.org/licenses/LICENSE-2.0
//  Unless required by applicable law or agreed to in writing, software distributed under the
//  License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
//  either express or implied. See the License for the specific language governing permissions
//  and limitations under the License.
//

#import <Foundation/Foundation.h>

#import "ICDNetworkManagerProtocol.h"



@protocol ICDControllerOneDocumentDataDelegate;



@interface ICDControllerOneDocumentData : NSObject

@property (strong, nonatomic, readonly) NSString *documentIdOrNil;
@property (strong, nonatomic, readonly) NSDictionary *fullDocument;

@property (weak, nonatomic) id<ICDControllerOneDocumentDataDelegate> delegate;

- (id)initWithNetworkManager:(id<ICDNetworkManagerProtocol>)networkManagerOrNil
                databaseName:(NSString *)databaseNameOrNil
                  documentId:(NSString *)documentIdOrNil;

- (BOOL)asyncGetFullDocument;
- (BOOL)asyncUpdateDocumentWithData:(NSDictionary *)data;

@end



@protocol ICDControllerOneDocumentDataDelegate <NSObject>

- (void)icdControllerOneDocumentData:(ICDControllerOneDocumentData *)data
             didGetFullDocWithResult:(BOOL)success;

- (void)icdControllerOneDocumentData:(ICDControllerOneDocumentData *)data
              didUpdateDocWithResult:(BOOL)success;

@end
