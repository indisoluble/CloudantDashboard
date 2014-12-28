//
//  ICDRequestAddRevisionDelegate.h
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 28/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import <Foundation/Foundation.h>



@protocol ICDRequestProtocol;
@class ICDModelDocument;



@protocol ICDRequestAddRevisionDelegate <NSObject>

- (void)requestAddRevision:(id<ICDRequestProtocol>)request didAddRevision:(ICDModelDocument *)revision;
- (void)requestAddRevision:(id<ICDRequestProtocol>)request didFailWithError:(NSError *)error;

@end
