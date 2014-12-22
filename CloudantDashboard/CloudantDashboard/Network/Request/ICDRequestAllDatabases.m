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



#define ICDREQUESTALLDATABASES_PATHPATTERN  @"/_all_dbs"



@interface ICDRequestAllDatabases ()

@end



@implementation ICDRequestAllDatabases

#pragma mark - ICDRequestProtocol methods
- (void)executeRequestWithObjectManager:(id)objectManager
{
    RKObjectManager *thisObjectManager = (RKObjectManager *)objectManager;
    
    [thisObjectManager getObjectsAtPath:ICDREQUESTALLDATABASES_PATHPATTERN
                             parameters:nil
                                success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                    ICDLogInfo(@"Success: %@", mappingResult.array);
                                } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                    ICDLogError(@"Error: %@", error);
                                }];
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
