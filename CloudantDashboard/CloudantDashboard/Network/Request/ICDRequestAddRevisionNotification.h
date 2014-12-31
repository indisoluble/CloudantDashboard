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
extern NSString * const kICDRequestAddRevisionNotificationDidAddRevisionUserInfoKeyRevision;

extern NSString * const kICDRequestAddRevisionNotificationDidFail;
extern NSString * const kICDRequestAddRevisionNotificationDidFailUserInfoKeyError;



@interface ICDRequestAddRevisionNotification : NSObject

- (id)initWithNotificationCenter:(NSNotificationCenter *)notificationCenterOrNil;

- (void)addDidAddRevisionNotificationObserver:(id)observer selector:(SEL)aSelector sender:(id)sender;
- (void)removeDidAddRevisionNotificationObserver:(id)observer sender:(id)sender;
- (void)postDidAddRevisionNotificationWithSender:(id)sender revision:(ICDModelDocument *)revision;

- (void)addDidFailNotificationObserver:(id)observer selector:(SEL)aSelector sender:(id)sender;
- (void)removeDidFailNotificationObserver:(id)observer sender:(id)sender;
- (void)postDidFailNotificationWithSender:(id)sender error:(NSError *)error;

@end
