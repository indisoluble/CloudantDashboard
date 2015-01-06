//
//  ICDControllerDocumentsData.h
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 04/01/2015.
//  Copyright (c) 2015 Enrique de la Torre. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ICDNetworkManagerProtocol.h"

#import "ICDModelDocument.h"



@protocol ICDControllerDocumentsDataDelegate;



@interface ICDControllerDocumentsData : NSObject

@property (strong, nonatomic, readonly) NSString *databaseNameOrNil;
@property (strong, nonatomic, readonly) id<ICDNetworkManagerProtocol> networkManager;

@property (assign, nonatomic, readonly) BOOL isRefreshingDocs;

@property (weak, nonatomic) id<ICDControllerDocumentsDataDelegate> delegate;

- (id)initWithDatabaseName:(NSString *)databaseNameOrNil
            networkManager:(id<ICDNetworkManagerProtocol>)networkManagerOrNil;

- (NSInteger)numberOfDocuments;
- (ICDModelDocument *)documentAtIndex:(NSUInteger)index;

- (BOOL)asyncRefreshDocs;
- (BOOL)asyncCreateDoc;
- (BOOL)asyncBulkDocs;
- (BOOL)asyncDeleteDocAtIndex:(NSUInteger)index;

@end



@protocol ICDControllerDocumentsDataDelegate <NSObject>

- (void)icdControllerDocumentsDataWillRefreshDocs:(ICDControllerDocumentsData *)data;
- (void)icdControllerDocumentsData:(ICDControllerDocumentsData *)data
          didRefreshDocsWithResult:(BOOL)success;

- (void)icdControllerDocumentsData:(ICDControllerDocumentsData *)data
            didCreateDocsAtIndexes:(NSIndexSet *)indexes;

- (void)icdControllerDocumentsData:(ICDControllerDocumentsData *)data
               didUpdateDocAtIndex:(NSUInteger)index;

- (void)icdControllerDocumentsData:(ICDControllerDocumentsData *)data
               didDeleteDocAtIndex:(NSUInteger)index;

@end
