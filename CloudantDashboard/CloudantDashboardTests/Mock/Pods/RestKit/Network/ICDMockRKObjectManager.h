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

@property (strong, nonatomic) ICDMockRKMappingResult  *postObjectSuccessResult;
@property (strong, nonatomic) NSError *postObjectFailureResult;

- (void)addResponseDescriptor:(id)responseDescriptor;
- (void)removeResponseDescriptor:(id)responseDescriptor;

- (void)postObject:(id)object
              path:(NSString *)path
        parameters:(NSDictionary *)parameters
           success:(void (^)(id operation, ICDMockRKMappingResult *mappingResult))success
           failure:(void (^)(id *operation, NSError *error))failure;

@end
