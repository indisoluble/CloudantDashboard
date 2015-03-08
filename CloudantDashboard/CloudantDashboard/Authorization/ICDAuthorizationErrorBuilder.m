//
//  ICDAuthorizationErrorBuilder.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 21/12/2014.
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
