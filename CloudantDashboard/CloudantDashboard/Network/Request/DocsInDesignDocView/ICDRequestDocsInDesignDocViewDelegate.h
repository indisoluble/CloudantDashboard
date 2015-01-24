//
//  ICDRequestDocsInDesignDocViewDelegate.h
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 23/01/2015.
//  Copyright (c) 2015 Enrique de la Torre. All rights reserved.
//

#import <Foundation/Foundation.h>



@protocol ICDRequestProtocol;



@protocol ICDRequestDocsInDesignDocViewDelegate <NSObject>

- (void)requestDocsInDesignDocView:(id<ICDRequestProtocol>)request didGetDocuments:(NSArray *)documents;
- (void)requestDocsInDesignDocView:(id<ICDRequestProtocol>)request didFailWithError:(NSError *)error;

@end
