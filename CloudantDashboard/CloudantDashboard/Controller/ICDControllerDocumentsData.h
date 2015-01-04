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

@property (strong, nonatomic, readonly) NSString *databaseName;
@property (strong, nonatomic, readonly) id<ICDNetworkManagerProtocol> networkManager;

@property (assign, nonatomic, readonly) BOOL isRefreshingDocs;

@property (weak, nonatomic) id<ICDControllerDocumentsDataDelegate> delegate;

- (NSInteger)numberOfDocuments;
- (ICDModelDocument *)documentAtIndex:(NSUInteger)index;

- (BOOL)asyncRefreshDocsWithNetworkManager:(id<ICDNetworkManagerProtocol>)networkManager
                              databaseName:(NSString *)databaseName;
- (BOOL)asyncRefreshDocs;
- (BOOL)asyncCreateDoc;
- (BOOL)asyncDeleteDocAtIndex:(NSUInteger)index;

- (void)reset;

@end



@protocol ICDControllerDocumentsDataDelegate <NSObject>

- (void)icdControllerDocumentsDataWillRefreshDocs:(ICDControllerDocumentsData *)data;
- (void)icdControllerDocumentsData:(ICDControllerDocumentsData *)data
          didRefreshDocsWithResult:(BOOL)success;

- (void)icdControllerDocumentsData:(ICDControllerDocumentsData *)data
               didCreateDocAtIndex:(NSUInteger)index;

- (void)icdControllerDocumentsData:(ICDControllerDocumentsData *)data
               didUpdateDocAtIndex:(NSUInteger)index;

- (void)icdControllerDocumentsData:(ICDControllerDocumentsData *)data
               didDeleteDocAtIndex:(NSUInteger)index;

@end
