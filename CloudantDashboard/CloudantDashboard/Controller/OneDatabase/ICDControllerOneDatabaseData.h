//
//  ICDControllerOneDatabaseData.h
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 18/01/2015.
//  Copyright (c) 2015 Enrique de la Torre. All rights reserved.
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
