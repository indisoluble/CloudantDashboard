//
//  ICDRequestAllDocumentsForADatabase.h
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 23/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ICDRequestProtocol.h"
#import "ICDRequestAllDocumentsForADatabaseDelegate.h"



@interface ICDRequestAllDocumentsForADatabase : NSObject <ICDRequestProtocol>

@property (weak, nonatomic) id<ICDRequestAllDocumentsForADatabaseDelegate> delegate;

- (id)initWithDatabaseName:(NSString *)dbName;

@end
