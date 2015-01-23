//
//  ICDControllerDocumentsDataProtocol.h
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 23/01/2015.
//  Copyright (c) 2015 Enrique de la Torre. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ICDControllerDocumentsDataDelegate.h"

#import "ICDNetworkManagerProtocol.h"

#import "ICDModelDocument.h"



@protocol ICDControllerDocumentsDataProtocol <NSObject>

@property (strong, nonatomic, readonly) NSString *databaseNameOrNil;
@property (strong, nonatomic, readonly) id<ICDNetworkManagerProtocol> networkManager;

@property (assign, nonatomic, readonly) BOOL isRefreshingDocs;

@property (weak, nonatomic) id<ICDControllerDocumentsDataDelegate> delegate;

- (NSInteger)numberOfDocuments;
- (ICDModelDocument *)documentAtIndex:(NSUInteger)index;

- (BOOL)asyncRefreshDocs;

@optional
- (BOOL)asyncCreateDoc;
- (BOOL)asyncBulkDocsWithData:(NSDictionary *)data
               numberOfCopies:(NSUInteger)numberOfCopies;
- (BOOL)asyncDeleteDocAtIndex:(NSUInteger)index;

@end
