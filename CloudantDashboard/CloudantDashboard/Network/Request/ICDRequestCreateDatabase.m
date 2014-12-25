//
//  ICDRequestCreateDatabase.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 25/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import <RestKit/RestKit.h>

#import "ICDRequestCreateDatabase.h"

#import "ICDRequestResponseValueOk.h"
#import "ICDRequestResponseValueError.h"

#import "RKObjectManager+Helper.h"



#define ICDREQUESTCREATEDATABASE_PATH_FORMAT    @"/%@"

#define ICDREQUESTCREATEDATABASE_STATUSCODE_CREATED                 201
#define ICDREQUESTCREATEDATABASE_STATUSCODE_CREATEDWITHOUTQUORUM    202
#define ICDREQUESTCREATEDATABASE_STATUSCODE_INVALIDNAME             RKStatusCodeClassClientError
#define ICDREQUESTCREATEDATABASE_STATUSCODE_ALREADYEXISTS           412



@interface ICDRequestCreateDatabase ()

@property (strong, nonatomic) NSString *dbName;
@property (strong, nonatomic) NSString *path;
@property (strong, nonatomic) NSArray *responseDescriptors;

@end



@implementation ICDRequestCreateDatabase

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
        NSCharacterSet *whiteSpacesAndNewLines = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        NSString *trimmedDBName = (dbName ? [dbName stringByTrimmingCharactersInSet:whiteSpacesAndNewLines] : nil);
        
        if (!trimmedDBName || ([trimmedDBName length] == 0))
        {
            self = nil;
        }
        else
        {
            _dbName = trimmedDBName;
            _path = [NSString stringWithFormat:ICDREQUESTCREATEDATABASE_PATH_FORMAT, _dbName];
            _responseDescriptors = [ICDRequestCreateDatabase responseDescriptorsWithPath:_path];
        }
    }
    
    return self;
}


#pragma mark - ICDRequestProtocol methods
- (void)executeRequestWithObjectManager:(id)objectManager
{
    RKObjectManager *thisObjectManager = (RKObjectManager *)objectManager;
    NSArray *thisResponseDescriptors = self.responseDescriptors;
    
    // Add configuration
    [thisObjectManager addResponseDescriptorsFromArray:thisResponseDescriptors];
    
    // Execute request
    __weak ICDRequestCreateDatabase *weakSelf = self;
    
    void (^successBlock)(RKObjectRequestOperation *op, RKMappingResult *mapResult) = ^(RKObjectRequestOperation *op, RKMappingResult *mapResult)
    {
        // Remove configuration
        [thisObjectManager removeResponseDescriptorsFromArray:thisResponseDescriptors];
        
        // Notify
        __strong ICDRequestCreateDatabase *strongSelf = weakSelf;
        if (strongSelf && strongSelf.delegate)
        {
            [strongSelf.delegate requestCreateDatabase:strongSelf didCreateDatabaseWithName:strongSelf.dbName];
        }
    };
    
    void (^failureBlock)(RKObjectRequestOperation *op, NSError *err) = ^(RKObjectRequestOperation *op, NSError *err)
    {
        // Remove configuration
        [thisObjectManager removeResponseDescriptorsFromArray:thisResponseDescriptors];
        
        // Notify
        __strong ICDRequestCreateDatabase *strongSelf = weakSelf;
        if (strongSelf)
        {
            [strongSelf.delegate requestCreateDatabase:strongSelf didFailWithError:err];
        }
    };
    
    [thisObjectManager putObject:nil path:self.path parameters:nil success:successBlock failure:failureBlock];
}


#pragma mark - Private class methods
+ (NSArray *)responseDescriptorsWithPath:(NSString *)path
{
    return @[[ICDRequestCreateDatabase responseDescriptorForSuccessWithPath:path],
             [ICDRequestCreateDatabase responseDescriptorForFailureWithPath:path]];
}

+ (RKResponseDescriptor *)responseDescriptorForSuccessWithPath:(NSString *)path
{
    // Mapping
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[ICDRequestResponseValueOk class]];
    [mapping addAttributeMappingsFromArray:@[ICDREQUESTRESPONSEVALUE_PROPERTY_KEY_OK]];
    
    // Status code
    NSMutableIndexSet *statusCodes = [NSMutableIndexSet indexSetWithIndex:ICDREQUESTCREATEDATABASE_STATUSCODE_CREATED];
    [statusCodes addIndex:ICDREQUESTCREATEDATABASE_STATUSCODE_CREATEDWITHOUTQUORUM];
    
    // Response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping
                                                                                            method:RKRequestMethodPUT
                                                                                       pathPattern:path
                                                                                           keyPath:nil
                                                                                       statusCodes:statusCodes];
    
    return responseDescriptor;
}

+ (RKResponseDescriptor *)responseDescriptorForFailureWithPath:(NSString *)path
{
    // Mapping
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[ICDRequestResponseValueError class]];
    [mapping addAttributeMappingsFromArray:@[ICDREQUESTRESPONSEVALUEERROR_PROPERTY_KEY_ERROR,
                                             ICDREQUESTRESPONSEVALUEERROR_PROPERTY_KEY_REASON]];
    
    // Status code
    NSMutableIndexSet *statusCodes = [NSMutableIndexSet indexSetWithIndex:ICDREQUESTCREATEDATABASE_STATUSCODE_INVALIDNAME];
    [statusCodes addIndex:ICDREQUESTCREATEDATABASE_STATUSCODE_ALREADYEXISTS];
    
    // Response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping
                                                                                            method:RKRequestMethodPUT
                                                                                       pathPattern:path
                                                                                           keyPath:nil
                                                                                       statusCodes:statusCodes];
    
    return responseDescriptor;
}

@end
