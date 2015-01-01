//
//  ICDMockRKObjectManager.h
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 31/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ICDMockRKMappingResult.h"



@interface ICDMockRKObjectManager : NSObject

@property (strong, nonatomic) ICDMockRKMappingResult  *successResult;
@property (strong, nonatomic) NSError *failureResult;

- (void)addRequestDescriptor:(id)requestDescriptor;
- (void)removeRequestDescriptor:(id)requestDescriptor;

- (void)addResponseDescriptor:(id)responseDescriptor;
- (void)addResponseDescriptorsFromArray:(NSArray *)responseDescriptors;
- (void)removeResponseDescriptor:(id)responseDescriptor;
- (void)removeResponseDescriptorsFromArray:(NSArray *)responseDescriptors;

- (void)getObject:(id)object
             path:(NSString *)path
       parameters:(NSDictionary *)parameters
          success:(void (^)(id operation, ICDMockRKMappingResult *mappingResult))success
          failure:(void (^)(id operation, NSError *error))failure;
- (void)getObjectsAtPath:(NSString *)path
              parameters:(NSDictionary *)parameters
                 success:(void (^)(id operation, ICDMockRKMappingResult *mappingResult))success
                 failure:(void (^)(id operation, NSError *error))failure;
- (void)postObject:(id)object
              path:(NSString *)path
        parameters:(NSDictionary *)parameters
           success:(void (^)(id operation, ICDMockRKMappingResult *mappingResult))success
           failure:(void (^)(id *operation, NSError *error))failure;
- (void)putObject:(id)object
             path:(NSString *)path
       parameters:(NSDictionary *)parameters
          success:(void (^)(id operation, ICDMockRKMappingResult *mappingResult))success
          failure:(void (^)(id operation, NSError *error))failure;
- (void)deleteObject:(id)object
                path:(NSString *)path
          parameters:(NSDictionary *)parameters
             success:(void (^)(id operation, ICDMockRKMappingResult *mappingResult))success
             failure:(void (^)(id operation, NSError *error))failure;

@end
