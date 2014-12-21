//
//  ICDAuthorizationErrorBuilder.h
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 21/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import <Foundation/Foundation.h>



typedef enum {
    ICDAuthorizationErrorBuilder_errorType_authorizationDataNotFound = 0
} ICDAuthorizationErrorBuilder_errorType;



extern NSString * const kICDAuthorizationErrorDomain;



@interface ICDAuthorizationErrorBuilder : NSObject

+ (BOOL)isErrorAuthorizationDataNotFound:(NSError *)error;
+ (NSError *)errorAuthorizationDataNotFound;

+ (NSError *)errorWithType:(ICDAuthorizationErrorBuilder_errorType)type
      localizedDescription:(NSString *)description;

@end
