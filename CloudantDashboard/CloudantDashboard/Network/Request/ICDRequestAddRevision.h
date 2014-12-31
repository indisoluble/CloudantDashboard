//
//  ICDRequestAddRevision.h
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 28/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ICDRequestProtocol.h"
#import "ICDRequestAddRevisionDelegate.h"
#import "ICDRequestAddRevisionNotification.h"



@interface ICDRequestAddRevision : NSObject <ICDRequestProtocol>

@property (strong, nonatomic, readonly) ICDRequestAddRevisionNotification *notification;

@property (weak, nonatomic) id<ICDRequestAddRevisionDelegate> delegate;

- (id)initWithDatabaseName:(NSString *)dbName
                documentId:(NSString *)docId
               documentRev:(NSString *)docRev
              documentData:(NSDictionary *)docData;

- (id)initWithDatabaseName:(NSString *)dbName
                documentId:(NSString *)docId
               documentRev:(NSString *)docRev
              documentData:(NSDictionary *)docData
              notification:(ICDRequestAddRevisionNotification *)notificationOrNil;

@end
