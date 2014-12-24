//
//  ICDRequestAllDatabases.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 22/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import <RestKit/RestKit.h>

#import "ICDRequestAllDatabases.h"

#import "ICDModelDatabase.h"



#define ICDREQUESTALLDATABASES_PATH @"/_all_dbs"



@interface ICDRequestAllDatabases ()

@end



@implementation ICDRequestAllDatabases

#pragma mark - ICDRequestProtocol methods
- (void)executeRequestWithObjectManager:(id)objectManager
{
    RKObjectManager *thisObjectManager = (RKObjectManager *)objectManager;
    RKResponseDescriptor *responseDescriptor = [ICDRequestAllDatabases responseDescriptor];
    
    [self executeRequestWithObjectManager:thisObjectManager responseDescriptor:responseDescriptor];
}


#pragma mark - Private methods
- (void)executeRequestWithObjectManager:(RKObjectManager *)objectManager responseDescriptor:(RKResponseDescriptor *)responseDescriptor
{
    // Add configuration
    [objectManager addResponseDescriptor:responseDescriptor];
    
    // Execute request
    __weak ICDRequestAllDatabases *weakSelf = self;
    
    void (^successBlock)(RKObjectRequestOperation *op, RKMappingResult *mapResult) = ^(RKObjectRequestOperation *op, RKMappingResult *mapResult)
    {
        // Remove configuration
        [objectManager removeResponseDescriptor:responseDescriptor];
        
        // Notify
        __strong ICDRequestAllDatabases *strongSelf = weakSelf;
        if (strongSelf && strongSelf.delegate)
        {
            [strongSelf.delegate requestAllDatabases:strongSelf didGetDatabases:mapResult.array];
        }
    };
    
    void (^failureBlock)(RKObjectRequestOperation *op, NSError *err) = ^(RKObjectRequestOperation *op, NSError *err)
    {
        // Remove configuration
        [objectManager removeResponseDescriptor:responseDescriptor];
        
        // Notify
        __strong ICDRequestAllDatabases *strongSelf = weakSelf;
        if (strongSelf && strongSelf.delegate)
        {
            [strongSelf.delegate requestAllDatabases:strongSelf didFailWithError:err];
        }
    };
    
    [objectManager getObjectsAtPath:ICDREQUESTALLDATABASES_PATH parameters:nil success:successBlock failure:failureBlock];
}


#pragma mark - Private class methods
+ (RKResponseDescriptor *)responseDescriptor
{
    // Mapping
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[ICDModelDatabase class]];
    [mapping addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:nil
                                                                      toKeyPath:ICDMODELDATABASE_PROPERTY_KEY_NAME]];
    
    // Status code
    NSIndexSet *statusCodes = [NSIndexSet indexSetWithIndex:RKStatusCodeClassSuccessful];
    
    // Response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping
                                                                                            method:RKRequestMethodGET
                                                                                       pathPattern:ICDREQUESTALLDATABASES_PATH
                                                                                           keyPath:nil
                                                                                       statusCodes:statusCodes];
    
    return responseDescriptor;
}

@end
