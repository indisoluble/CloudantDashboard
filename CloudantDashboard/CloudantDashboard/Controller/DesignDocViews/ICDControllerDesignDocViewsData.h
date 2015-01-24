//
//  ICDControllerDesignDocViewsData.h
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 20/01/2015.
//  Copyright (c) 2015 Enrique de la Torre. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ICDNetworkManagerProtocol.h"

#import "ICDModelDocument.h"
#import "ICDModelDesignDocumentView.h"



@protocol ICDControllerDesignDocViewsDataDelegate;



@interface ICDControllerDesignDocViewsData : NSObject

@property (strong, nonatomic, readonly) NSString *databaseNameOrNil;
@property (strong, nonatomic, readonly) ICDModelDocument *designDocOrNil;
@property (strong, nonatomic, readonly) id<ICDNetworkManagerProtocol> networkManager;

@property (assign, nonatomic, readonly) BOOL isRefreshingDesignDocViews;

@property (weak, nonatomic) id<ICDControllerDesignDocViewsDataDelegate> delegate;

- (id)initWithNetworkManager:(id<ICDNetworkManagerProtocol>)networkManagerOrNil
                databaseName:(NSString *)databaseNameOrNil
                   designDoc:(ICDModelDocument *)designDocOrNil;

- (NSInteger)numberOfDesignDocViews;
- (ICDModelDesignDocumentView *)designDocViewAtIndex:(NSUInteger)index;

- (BOOL)asyncRefreshDesignDocViews;

@end



@protocol ICDControllerDesignDocViewsDataDelegate <NSObject>

- (void)icdControllerDesignDocViewsDataWillRefreshDesignDocViews:(ICDControllerDesignDocViewsData *)data;
- (void)icdControllerDesignDocViewsData:(ICDControllerDesignDocViewsData *)data
     didRefreshDesignDocViewsWithResult:(BOOL)success;

@end
