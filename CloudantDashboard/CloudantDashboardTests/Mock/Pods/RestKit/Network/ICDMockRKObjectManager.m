//
//  ICDMockRKObjectManager.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 31/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import "ICDMockRKObjectManager.h"



@interface ICDMockRKObjectManager ()

@end



@implementation ICDMockRKObjectManager

#pragma mark - Public methods
- (void)addResponseDescriptor:(id)responseDescriptor
{
    // Empty
}

- (void)removeResponseDescriptor:(id)responseDescriptor
{
    // Empty
}

- (void)postObject:(id)object
              path:(NSString *)path
        parameters:(NSDictionary *)parameters
           success:(void (^)(id operation, ICDMockRKMappingResult *mappingResult))success
           failure:(void (^)(id *operation, NSError *error))failure
{
    if (self.postObjectSuccessResult)
    {
        success(nil, self.postObjectSuccessResult);
    }
    else
    {
        failure(nil, self.postObjectFailureResult);
    }
}

@end
