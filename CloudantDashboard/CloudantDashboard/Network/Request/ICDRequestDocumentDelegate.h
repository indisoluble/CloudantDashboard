//
//  ICDRequestDocumentDelegate.h
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 23/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import <Foundation/Foundation.h>



@protocol ICDRequestProtocol;



@protocol ICDRequestDocumentDelegate <NSObject>

- (void)requestDocument:(id<ICDRequestProtocol>)request didGetDocument:(NSAttributedString *)document;
- (void)requestDocument:(id<ICDRequestProtocol>)request didFailWithError:(NSError *)error;

@end
