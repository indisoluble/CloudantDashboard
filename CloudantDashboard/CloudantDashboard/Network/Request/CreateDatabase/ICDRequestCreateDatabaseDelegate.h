//
//  ICDRequestCreateDatabaseDelegate.h
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 25/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import <Foundation/Foundation.h>



@protocol ICDRequestProtocol;



@protocol ICDRequestCreateDatabaseDelegate <NSObject>

- (void)requestCreateDatabase:(id<ICDRequestProtocol>)request didCreateDatabaseWithName:(NSString *)dbName;
- (void)requestCreateDatabase:(id<ICDRequestProtocol>)request didFailWithError:(NSError *)error;

@end
