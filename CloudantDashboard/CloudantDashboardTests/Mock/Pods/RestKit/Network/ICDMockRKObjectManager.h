//
//  ICDMockRKObjectManager.h
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
