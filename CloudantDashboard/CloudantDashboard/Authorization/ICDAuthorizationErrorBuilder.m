//
//  ICDAuthorizationErrorBuilder.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 21/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import "ICDAuthorizationErrorBuilder.h"



NSString * const kICDAuthorizationErrorDomain = @"kICDAuthorizationErrorDomain";



@interface ICDAuthorizationErrorBuilder ()

@end



@implementation ICDAuthorizationErrorBuilder

#pragma mark - Public class methods
+ (BOOL)isErrorAuthorizationDataNotFound:(NSError *)error
{
    return (error &&
            [[error domain] isEqualToString:kICDAuthorizationErrorDomain] &&
            ([error code] == ICDAuthorizationErrorBuilder_errorType_authorizationDataNotFound));
}

+ (NSError *)errorAuthorizationDataNotFound
{
    return [ICDAuthorizationErrorBuilder errorWithType:ICDAuthorizationErrorBuilder_errorType_authorizationDataNotFound
                                  localizedDescription:NSLocalizedString(@"Authorization data not found", @"Authorization data not found")];
}

+ (BOOL)isErrorAuthorizationDataNotValid:(NSError *)error
{
    return (error &&
            [[error domain] isEqualToString:kICDAuthorizationErrorDomain] &&
            ([error code] == ICDAuthorizationErrorBuilder_errorType_authorizationDataNotValid));
}

+ (NSError *)errorAuthorizationDataNotValid
{
    return [ICDAuthorizationErrorBuilder errorWithType:ICDAuthorizationErrorBuilder_errorType_authorizationDataNotValid
                                  localizedDescription:NSLocalizedString(@"Authorization data not valid", @"Authorization data not valid")];
}

+ (BOOL)isErrorAuthorizationDataNotSaved:(NSError *)error
{
    return (error &&
            [[error domain] isEqualToString:kICDAuthorizationErrorDomain] &&
            ([error code] == ICDAuthorizationErrorBuilder_errorType_authorizationDataNotSaved));
}

+ (NSError *)errorAuthorizationDataNotSaved
{
    return [ICDAuthorizationErrorBuilder errorWithType:ICDAuthorizationErrorBuilder_errorType_authorizationDataNotSaved
                                  localizedDescription:NSLocalizedString(@"Authorization data not saved", @"Authorization data not saved")];
}

+ (BOOL)isErrorAuthorizationDataNotDeleted:(NSError *)error
{
    return (error &&
            [[error domain] isEqualToString:kICDAuthorizationErrorDomain] &&
            ([error code] == ICDAuthorizationErrorBuilder_errorType_authorizationDataNotDeleted));
}

+ (NSError *)errorAuthorizationDataNotDeleted
{
    return [ICDAuthorizationErrorBuilder errorWithType:ICDAuthorizationErrorBuilder_errorType_authorizationDataNotDeleted
                                  localizedDescription:NSLocalizedString(@"Authorization data not deleted", @"Authorization data not deleted")];
}

+ (NSError *)errorWithType:(ICDAuthorizationErrorBuilder_errorType)type
      localizedDescription:(NSString *)description
{
    return [NSError errorWithDomain:kICDAuthorizationErrorDomain
                               code:type
                           userInfo:@{NSLocalizedDescriptionKey: description}];
}

@end
