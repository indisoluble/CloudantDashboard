//
//  ICDAuthorizationErrorBuilder.h
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 21/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import <Foundation/Foundation.h>



typedef enum {
    ICDAuthorizationErrorBuilder_errorType_authorizationDataNotFound = 0,
    ICDAuthorizationErrorBuilder_errorType_authorizationDataNotValid,
    ICDAuthorizationErrorBuilder_errorType_authorizationDataNotSaved,
    ICDAuthorizationErrorBuilder_errorType_authorizationDataNotDeleted
} ICDAuthorizationErrorBuilder_errorType;



extern NSString * const kICDAuthorizationErrorDomain;



@interface ICDAuthorizationErrorBuilder : NSObject

+ (BOOL)isErrorAuthorizationDataNotFound:(NSError *)error;
+ (NSError *)errorAuthorizationDataNotFound;

+ (BOOL)isErrorAuthorizationDataNotValid:(NSError *)error;
+ (NSError *)errorAuthorizationDataNotValid;

+ (BOOL)isErrorAuthorizationDataNotSaved:(NSError *)error;
+ (NSError *)errorAuthorizationDataNotSaved;

+ (BOOL)isErrorAuthorizationDataNotDeleted:(NSError *)error;
+ (NSError *)errorAuthorizationDataNotDeleted;

+ (NSError *)errorWithType:(ICDAuthorizationErrorBuilder_errorType)type
      localizedDescription:(NSString *)description;

@end
