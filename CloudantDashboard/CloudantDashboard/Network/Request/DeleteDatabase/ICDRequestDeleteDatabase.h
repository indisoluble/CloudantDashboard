//
//  ICDRequestDeleteDatabase.h
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 24/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ICDRequestProtocol.h"
#import "ICDRequestDeleteDatabaseDelegate.h"



@interface ICDRequestDeleteDatabase : NSObject <ICDRequestProtocol>

@property (weak, nonatomic) id<ICDRequestDeleteDatabaseDelegate> delegate;

- (id)initWithDatabaseName:(NSString *)dbName;

@end
