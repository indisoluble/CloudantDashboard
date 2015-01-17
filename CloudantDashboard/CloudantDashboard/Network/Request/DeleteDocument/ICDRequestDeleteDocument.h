//
//  ICDRequestDeleteDocument.h
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 26/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ICDRequestProtocol.h"
#import "ICDRequestDeleteDocumentDelegate.h"



@interface ICDRequestDeleteDocument : NSObject <ICDRequestProtocol>

@property (weak, nonatomic) id<ICDRequestDeleteDocumentDelegate> delegate;

- (id)initWithDatabaseName:(NSString *)dbName
                documentId:(NSString *)documentId
               documentRev:(NSString *)documentRev;

@end
