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

#import "ICDLog.h"



#define ICDREQUESTALLDATABASES_PATH         @"/_all_dbs"
#define ICDREQUESTALLDATABASES_PATHPATTERN  ICDREQUESTALLDATABASES_PATH



@interface ICDRequestAllDatabases ()

@end



@implementation ICDRequestAllDatabases

#pragma mark - ICDRequestProtocol methods
- (void)executeRequestWithObjectManager:(id)objectManager
{
    __weak ICDRequestAllDatabases *weakSelf = self;
    
    void (^successBlock)(RKObjectRequestOperation *op, RKMappingResult *mapResult) = ^(RKObjectRequestOperation *op, RKMappingResult *mapResult)
    {
        __strong ICDRequestAllDatabases *strongSelf = weakSelf;
        if (strongSelf && strongSelf.delegate)
        {
            [strongSelf.delegate requestAllDatabases:strongSelf didGetDatabases:mapResult.array];
        }
    };
    
    void (^failureBlock)(RKObjectRequestOperation *op, NSError *err) = ^(RKObjectRequestOperation *op, NSError *err)
    {
        __strong ICDRequestAllDatabases *strongSelf = weakSelf;
        if (strongSelf && strongSelf.delegate)
        {
            [strongSelf.delegate requestAllDatabases:strongSelf didFailWithError:err];
        }
    };
    
    RKObjectManager *thisObjectManager = (RKObjectManager *)objectManager;
    
    [thisObjectManager getObjectsAtPath:ICDREQUESTALLDATABASES_PATH
                             parameters:nil
                                success:successBlock
                                failure:failureBlock];
}

+ (void)configureObjectManager:(id)objectManager
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
                                                                                       pathPattern:ICDREQUESTALLDATABASES_PATHPATTERN
                                                                                           keyPath:nil
                                                                                       statusCodes:statusCodes];
    
    // Configure
    [(RKObjectManager *)objectManager addResponseDescriptor:responseDescriptor];
}

@end
