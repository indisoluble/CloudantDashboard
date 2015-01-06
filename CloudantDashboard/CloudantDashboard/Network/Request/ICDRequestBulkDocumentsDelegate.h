//
//  ICDRequestBulkDocumentsDelegate.h
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 06/01/2015.
//  Copyright (c) 2015 Enrique de la Torre. All rights reserved.
//

#import <Foundation/Foundation.h>



@protocol ICDRequestProtocol;



@protocol ICDRequestBulkDocumentsDelegate <NSObject>

- (void)requestBulkDocuments:(id<ICDRequestProtocol>)request didBulkDocuments:(NSArray *)documents;
- (void)requestBulkDocuments:(id<ICDRequestProtocol>)request didFailWithError:(NSError *)error;

@end
