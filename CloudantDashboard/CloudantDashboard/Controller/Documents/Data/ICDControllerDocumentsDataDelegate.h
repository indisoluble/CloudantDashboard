//
//  ICDControllerDocumentsDataDelegate.h
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 23/01/2015.
//  Copyright (c) 2015 Enrique de la Torre. All rights reserved.
//

#import <Foundation/Foundation.h>



@protocol ICDControllerDocumentsDataProtocol;



@protocol ICDControllerDocumentsDataDelegate <NSObject>

- (void)icdControllerDocumentsDataWillRefreshDocs:(id<ICDControllerDocumentsDataProtocol>)data;
- (void)icdControllerDocumentsData:(id<ICDControllerDocumentsDataProtocol>)data
          didRefreshDocsWithResult:(BOOL)success;

- (void)icdControllerDocumentsData:(id<ICDControllerDocumentsDataProtocol>)data
            didCreateDocsAtIndexes:(NSIndexSet *)indexes;

- (void)icdControllerDocumentsData:(id<ICDControllerDocumentsDataProtocol>)data
               didUpdateDocAtIndex:(NSUInteger)index;

- (void)icdControllerDocumentsData:(id<ICDControllerDocumentsDataProtocol>)data
               didDeleteDocAtIndex:(NSUInteger)index;

@end
