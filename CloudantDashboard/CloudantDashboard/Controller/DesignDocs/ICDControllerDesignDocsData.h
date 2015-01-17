//
//  ICDControllerDesignDocsData.h
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 17/01/2015.
//  Copyright (c) 2015 Enrique de la Torre. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ICDNetworkManagerProtocol.h"

#import "ICDModelDocument.h"



@protocol ICDControllerDesignDocsDataDelegate;



@interface ICDControllerDesignDocsData : NSObject

@property (strong, nonatomic, readonly) NSString *databaseNameOrNil;
@property (strong, nonatomic, readonly) id<ICDNetworkManagerProtocol> networkManager;

@property (assign, nonatomic, readonly) BOOL isRefreshingDesignDocs;

@property (weak, nonatomic) id<ICDControllerDesignDocsDataDelegate> delegate;

- (id)initWithDatabaseName:(NSString *)databaseNameOrNil
            networkManager:(id<ICDNetworkManagerProtocol>)networkManagerOrNil;

- (NSInteger)numberOfDesignDocs;
- (ICDModelDocument *)designDocAtIndex:(NSUInteger)index;

- (BOOL)asyncRefreshDesignDocs;

@end



@protocol ICDControllerDesignDocsDataDelegate <NSObject>

- (void)icdControllerDesignDocsDataWillRefreshDesignDocs:(ICDControllerDesignDocsData *)data;
- (void)icdControllerDesignDocsData:(ICDControllerDesignDocsData *)data
     didRefreshDesignDocsWithResult:(BOOL)success;

@end
