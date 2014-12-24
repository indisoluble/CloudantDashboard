//
//  ICDRequestDeleteDatabase.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 24/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import <RestKit/RestKit.h>

#import "ICDRequestDeleteDatabase.h"

#import "ICDRequestResponseValueOk.h"



#define ICDREQUESTDELETEDATABASE_PATH_FORMAT    @"/%@"



@interface ICDRequestDeleteDatabase ()

@property (strong, nonatomic) NSString *dbName;
@property (strong, nonatomic) NSString *path;
@property (strong, nonatomic) RKResponseDescriptor *responseDescriptor;

@end



@implementation ICDRequestDeleteDatabase

#pragma mark - Init object
- (id)init
{
    return [self initWithDatabaseName:nil];
}

- (id)initWithDatabaseName:(NSString *)dbName
{
    self = [super init];
    if (self)
    {
        if (!dbName)
        {
            self = nil;
        }
        else
        {
            _dbName = dbName;
            _path = [NSString stringWithFormat:ICDREQUESTDELETEDATABASE_PATH_FORMAT, _dbName];
            _responseDescriptor = [ICDRequestDeleteDatabase responseDescriptorForPath:_path];
        }
    }
    
    return self;
}


#pragma mark - ICDRequestProtocol methods
- (void)executeRequestWithObjectManager:(id)objectManager
{
    RKObjectManager *thisObjectManager = (RKObjectManager *)objectManager;
    RKResponseDescriptor *thisResponseDescriptor = self.responseDescriptor;
    
    // Add configuration
    [thisObjectManager addResponseDescriptor:thisResponseDescriptor];
    
    // Execute request
    __weak ICDRequestDeleteDatabase *weakSelf = self;
    
    void (^successBlock)(RKObjectRequestOperation *op, RKMappingResult *mapResult) = ^(RKObjectRequestOperation *op, RKMappingResult *mapResult)
    {
        // Remove configuration
        [thisObjectManager removeResponseDescriptor:thisResponseDescriptor];
        
        // Notify
        __strong ICDRequestDeleteDatabase *strongSelf = weakSelf;
        if (strongSelf && strongSelf.delegate)
        {
            [strongSelf.delegate requestDeleteDatabase:strongSelf didDeleteDatabaseWithName:strongSelf.dbName];
        }
    };
    
    void (^failureBlock)(RKObjectRequestOperation *op, NSError *err) = ^(RKObjectRequestOperation *op, NSError *err)
    {
        // Remove configuration
        [thisObjectManager removeResponseDescriptor:thisResponseDescriptor];
        
        // Notify
        __strong ICDRequestDeleteDatabase *strongSelf = weakSelf;
        if (strongSelf)
        {
            [strongSelf.delegate requestDeleteDatabase:strongSelf didFailWithError:err];
        }
    };
    
    [thisObjectManager deleteObject:nil path:self.path parameters:nil success:successBlock failure:failureBlock];
}


#pragma mark - Private class methods
+ (RKResponseDescriptor *)responseDescriptorForPath:(NSString *)path
{
    // Mapping
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[ICDRequestResponseValueOk class]];
    [mapping addAttributeMappingsFromArray:@[ICDREQUESTRESPONSEVALUE_PROPERTY_KEY_OK]];
    
    // Status code
    NSIndexSet *statusCodes = [NSIndexSet indexSetWithIndex:RKStatusCodeClassSuccessful];
    
    // Response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping
                                                                                            method:RKRequestMethodDELETE
                                                                                       pathPattern:path
                                                                                           keyPath:nil
                                                                                       statusCodes:statusCodes];
    
    return responseDescriptor;
}

@end
