//
//  ICDRequestAllDocuments.h
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 23/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ICDRequestProtocol.h"
#import "ICDRequestAllDocumentsDelegate.h"



@interface ICDRequestAllDocuments : NSObject <ICDRequestProtocol>

@property (weak, nonatomic) id<ICDRequestAllDocumentsDelegate> delegate;

- (id)initWithDatabaseName:(NSString *)dbName;

@end
