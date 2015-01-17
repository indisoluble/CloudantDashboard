//
//  ICDRequestAllDatabases.h
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 22/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ICDRequestProtocol.h"
#import "ICDRequestAllDatabasesDelegate.h"



@interface ICDRequestAllDatabases : NSObject <ICDRequestProtocol>

@property (weak, nonatomic) id<ICDRequestAllDatabasesDelegate> delegate;

@end
