//
//  ICDRequestCreateDatabase.h
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 25/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ICDRequestProtocol.h"
#import "ICDRequestCreateDatabaseDelegate.h"



@interface ICDRequestCreateDatabase : NSObject <ICDRequestProtocol>

@property (weak, nonatomic) id<ICDRequestCreateDatabaseDelegate> delegate;

- (id)initWithDatabaseName:(NSString *)dbName;

@end
