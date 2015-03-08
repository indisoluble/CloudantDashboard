//
//  ICDControllerOneDatabaseData.h
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 18/01/2015.
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
#import "ICDControllerOneDatabaseOptionProtocol.h"



@protocol ICDControllerOneDatabaseDataDelegate;



@interface ICDControllerOneDatabaseData : NSObject

@property (assign, nonatomic, readonly) BOOL isRefreshingDesignDocs;

@property (weak, nonatomic) id<ICDControllerOneDatabaseDataDelegate> delegate;

- (id)initWithDatabaseName:(NSString *)databaseNameOrNil
            networkManager:(id<ICDNetworkManagerProtocol>)networkManagerOrNil;

- (NSInteger)numberOfOptions;
- (id<ICDControllerOneDatabaseOptionProtocol>)optionAtIndex:(NSUInteger)index;

- (BOOL)asyncRefreshDesignDocs;

@end



@protocol ICDControllerOneDatabaseDataDelegate <NSObject>

- (void)icdControllerOneDatabaseDataWillRefreshDesignDocs:(ICDControllerOneDatabaseData *)data;
- (void)icdControllerOneDatabaseData:(ICDControllerOneDatabaseData *)data
      didRefreshDesignDocsWithResult:(BOOL)success;

@end
