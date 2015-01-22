//
//  ICDRequestDesignDocDelegate.h
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 21/01/2015.
//  Copyright (c) 2015 Enrique de la Torre. All rights reserved.
//

#import <Foundation/Foundation.h>



@protocol ICDRequestProtocol;
@class ICDModelDesignDocument;



@protocol ICDRequestDesignDocDelegate <NSObject>

- (void)requestDesignDoc:(id<ICDRequestProtocol>)request didGetDesignDoc:(ICDModelDesignDocument *)designDoc;
- (void)requestDesignDoc:(id<ICDRequestProtocol>)request didFailWithError:(NSError *)error;

@end
