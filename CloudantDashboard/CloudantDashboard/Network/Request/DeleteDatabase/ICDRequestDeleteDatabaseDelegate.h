//
//  ICDRequestDeleteDatabaseDelegate.h
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 24/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import <Foundation/Foundation.h>



@protocol ICDRequestProtocol;



@protocol ICDRequestDeleteDatabaseDelegate <NSObject>

- (void)requestDeleteDatabase:(id<ICDRequestProtocol>)request didDeleteDatabaseWithName:(NSString *)dbName;
- (void)requestDeleteDatabase:(id<ICDRequestProtocol>)request didFailWithError:(NSError *)error;

@end
