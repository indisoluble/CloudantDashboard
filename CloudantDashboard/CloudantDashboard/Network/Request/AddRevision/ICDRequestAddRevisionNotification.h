//
//  ICDRequestAddRevisionNotification.h
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 31/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ICDModelDocument.h"



extern NSString * const kICDRequestAddRevisionNotificationDidAddRevision;
extern NSString * const kICDRequestAddRevisionNotificationDidAddRevisionUserInfoKeyDatabaseName;
extern NSString * const kICDRequestAddRevisionNotificationDidAddRevisionUserInfoKeyRevision;

extern NSString * const kICDRequestAddRevisionNotificationDidFail;
extern NSString * const kICDRequestAddRevisionNotificationDidFailUserInfoKeyDatabaseName;
extern NSString * const kICDRequestAddRevisionNotificationDidFailUserInfoKeyDocumentId;
extern NSString * const kICDRequestAddRevisionNotificationDidFailUserInfoKeyError;



@interface ICDRequestAddRevisionNotification : NSObject

- (id)initWithNotificationCenter:(NSNotificationCenter *)notificationCenterOrNil;

- (void)addDidAddRevisionNotificationObserver:(id)observer selector:(SEL)aSelector;
- (void)removeDidAddRevisionNotificationObserver:(id)observer;
- (void)postDidAddRevisionNotificationWithDatabaseName:(NSString *)dbName revision:(ICDModelDocument *)revision;

- (void)addDidFailNotificationObserver:(id)observer selector:(SEL)aSelector;
- (void)removeDidFailNotificationObserver:(id)observer;
- (void)postDidFailNotificationWithDatabaseName:(NSString *)dbName documentId:(NSString *)documentId error:(NSError *)error;

+ (instancetype)sharedInstance;

@end
