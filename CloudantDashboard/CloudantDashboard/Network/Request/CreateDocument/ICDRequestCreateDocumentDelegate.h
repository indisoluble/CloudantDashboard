//
//  ICDRequestCreateDocumentDelegate.h
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 25/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import <Foundation/Foundation.h>



@protocol ICDRequestProtocol;
@class ICDModelDocument;



@protocol ICDRequestCreateDocumentDelegate <NSObject>

- (void)requestCreateDocument:(id<ICDRequestProtocol>)request didCreateDocument:(ICDModelDocument *)document;
- (void)requestCreateDocument:(id<ICDRequestProtocol>)request didFailWithError:(NSError *)error;

@end
