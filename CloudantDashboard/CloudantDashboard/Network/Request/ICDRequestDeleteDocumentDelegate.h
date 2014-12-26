//
//  ICDRequestDeleteDocumentDelegate.h
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 26/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import <Foundation/Foundation.h>



@protocol ICDRequestProtocol;
@class ICDModelDocument;



@protocol ICDRequestDeleteDocumentDelegate <NSObject>

- (void)requestDeleteDocument:(id<ICDRequestProtocol>)request
      didDeleteDocumentWithId:(NSString *)docId
                     revision:(NSString *)docRev;
- (void)requestDeleteDocument:(id<ICDRequestProtocol>)request
             didFailWithError:(NSError *)error;

@end
