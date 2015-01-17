//
//  ICDRequestAllDocumentsDelegate.h
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 23/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import <Foundation/Foundation.h>



@protocol ICDRequestProtocol;



@protocol ICDRequestAllDocumentsDelegate <NSObject>

- (void)requestAllDocuments:(id<ICDRequestProtocol>)request didGetDocuments:(NSArray *)documents;
- (void)requestAllDocuments:(id<ICDRequestProtocol>)request didFailWithError:(NSError *)error;

@end
