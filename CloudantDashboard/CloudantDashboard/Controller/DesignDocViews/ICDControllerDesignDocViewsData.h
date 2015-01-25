//
//  ICDControllerDesignDocViewsData.h
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 20/01/2015.
//  Copyright (c) 2015 Enrique de la Torre. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ICDNetworkManagerProtocol.h"

#import "ICDControllerDesignDocViewsCellCreatorProtocol.h"



@protocol ICDControllerDesignDocViewsDataDelegate;



@interface ICDControllerDesignDocViewsData : NSObject

@property (assign, nonatomic, readonly) BOOL isRefreshingCellCreators;

@property (weak, nonatomic) id<ICDControllerDesignDocViewsDataDelegate> delegate;

- (id)initWithNetworkManager:(id<ICDNetworkManagerProtocol>)networkManagerOrNil
                databaseName:(NSString *)databaseNameOrNil
                 designDocId:(NSString *)designDocIdOrNil;

- (NSInteger)numberOfCellCreators;
- (id<ICDControllerDesignDocViewsCellCreatorProtocol>)cellCreatorAtIndex:(NSUInteger)index;

- (BOOL)asyncRefreshCellCreators;

@end



@protocol ICDControllerDesignDocViewsDataDelegate <NSObject>

- (void)icdControllerDesignDocViewsDataWillRefreshCellCreators:(ICDControllerDesignDocViewsData *)data;
- (void)icdControllerDesignDocViewsData:(ICDControllerDesignDocViewsData *)data
       didRefreshCellCreatorsWithResult:(BOOL)success;

@end
