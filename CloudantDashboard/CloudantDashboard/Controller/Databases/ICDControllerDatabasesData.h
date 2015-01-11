//
//  ICDControllerDatabasesData.h
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 03/01/2015.
//  Copyright (c) 2015 Enrique de la Torre. All rights reserved.
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
