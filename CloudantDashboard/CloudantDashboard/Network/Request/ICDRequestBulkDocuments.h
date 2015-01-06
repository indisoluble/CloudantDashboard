//
//  ICDRequestBulkDocuments.h
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 06/01/2015.
//  Copyright (c) 2015 Enrique de la Torre. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ICDRequestProtocol.h"
#import "ICDRequestBulkDocumentsDelegate.h"



@interface ICDRequestBulkDocuments : NSObject <ICDRequestProtocol>

@property (weak, nonatomic) id<ICDRequestBulkDocumentsDelegate> delegate;

- (id)initWithDatabaseName:(NSString *)dbName;

@end
