//
//  ICDRequestAddRevisionNotification.h
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 31/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file
//  except in compliance with the License. You may obtain a copy of the License at
//    http://www.apache.org/licenses/LICENSE-2.0
//  Unless required by applicable law or agreed to in writing, software distributed under the
//  License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
//  either express or implied. See the License for the specific language governing permissions
//  and limitations under the License.
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
