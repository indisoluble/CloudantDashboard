//
//  ICDControllerDatabasesData.h
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 03/01/2015.
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

#import "ICDModelDatabase.h"



@protocol ICDControllerDatabasesDataDelegate;



@interface ICDControllerDatabasesData : NSObject

@property (strong, nonatomic, readonly) id<ICDNetworkManagerProtocol> networkManager;

@property (weak, nonatomic) id<ICDControllerDatabasesDataDelegate> delegate;

- (id)initWithUsername:(NSString *)usernameOrNil password:(NSString *)passwordOrNil;
- (id)initWithNetworkManager:(id<ICDNetworkManagerProtocol>)networkManagerOrNil;

- (NSInteger)numberOfDatabases;
- (ICDModelDatabase *)databaseAtIndex:(NSUInteger)index;

- (BOOL)asyncRefreshDBs;
- (BOOL)asyncCreateDBWithName:(NSString *)dbName;
- (BOOL)asyncDeleteDBAtIndex:(NSUInteger)index;

@end



@protocol ICDControllerDatabasesDataDelegate <NSObject>

- (void)icdControllerDatabasesDataWillRefreshDBs:(ICDControllerDatabasesData *)data;
- (void)icdControllerDatabasesData:(ICDControllerDatabasesData *)data
           didRefreshDBsWithResult:(BOOL)success;

- (void)icdControllerDatabasesData:(ICDControllerDatabasesData *)data
                didCreateDBAtIndex:(NSUInteger)index;

- (void)icdControllerDatabasesData:(ICDControllerDatabasesData *)data
                didDeleteDBAtIndex:(NSUInteger)index;

@end
