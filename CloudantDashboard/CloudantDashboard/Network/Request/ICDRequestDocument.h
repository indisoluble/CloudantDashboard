//
//  ICDRequestDocument.h
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 23/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ICDRequestProtocol.h"
#import "ICDRequestDocumentDelegate.h"



@interface ICDRequestDocument : NSObject <ICDRequestProtocol>

@property (weak, nonatomic) id<ICDRequestDocumentDelegate> delegate;

- (id)initWithDatabaseName:(NSString *)dbName documentId:(NSString *)documentId;

@end
