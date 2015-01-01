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
- (void)addRequestDescriptor:(id)requestDescriptor
{
    // Empty
}

- (void)removeRequestDescriptor:(id)requestDescriptor
{
    // Empty
}

- (void)addResponseDescriptor:(id)responseDescriptor
{
    // Empty
}

- (void)addResponseDescriptorsFromArray:(NSArray *)responseDescriptors
{
    // Array
}

- (void)removeResponseDescriptor:(id)responseDescriptor
{
    // Empty
}

- (void)removeResponseDescriptorsFromArray:(NSArray *)responseDescriptors
{
    // Empty
}

- (void)getObject:(id)object
             path:(NSString *)path
       parameters:(NSDictionary *)parameters
          success:(void (^)(id operation, ICDMockRKMappingResult *mappingResult))success
          failure:(void (^)(id operation, NSError *error))failure
{
    if (self.successResult)
    {
        success(nil, self.successResult);
    }
    else
    {
        failure(nil, self.failureResult);
    }
}

- (void)getObjectsAtPath:(NSString *)path
              parameters:(NSDictionary *)parameters
                 success:(void (^)(id operation, ICDMockRKMappingResult *mappingResult))success
                 failure:(void (^)(id operation, NSError *error))failure
{
    if (self.successResult)
    {
        success(nil, self.successResult);
    }
    else
    {
        failure(nil, self.failureResult);
    }
}

- (void)postObject:(id)object
              path:(NSString *)path
        parameters:(NSDictionary *)parameters
           success:(void (^)(id operation, ICDMockRKMappingResult *mappingResult))success
           failure:(void (^)(id *operation, NSError *error))failure
{
    if (self.successResult)
    {
        success(nil, self.successResult);
    }
    else
    {
        failure(nil, self.failureResult);
    }
}

- (void)putObject:(id)object
             path:(NSString *)path
       parameters:(NSDictionary *)parameters
          success:(void (^)(id operation, ICDMockRKMappingResult *mappingResult))success
          failure:(void (^)(id operation, NSError *error))failure
{
    if (self.successResult)
    {
        success(nil, self.successResult);
    }
    else
    {
        failure(nil, self.failureResult);
    }
}

- (void)deleteObject:(id)object
                path:(NSString *)path
          parameters:(NSDictionary *)parameters
             success:(void (^)(id operation, ICDMockRKMappingResult *mappingResult))success
             failure:(void (^)(id operation, NSError *error))failure
{
    if (self.successResult)
    {
        success(nil, self.successResult);
    }
    else
    {
        failure(nil, self.failureResult);
    }
}

@end
