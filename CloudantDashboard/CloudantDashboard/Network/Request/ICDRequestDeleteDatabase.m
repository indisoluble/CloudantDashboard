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
#import "ICDRequestResponseValueError.h"

#import "RKObjectManager+Helper.h"



#define ICDREQUESTDELETEDATABASE_PATH_FORMAT    @"/%@"

#define ICDREQUESTDELETEDATABASE_STATUSCODE_SUCCESS     RKStatusCodeClassSuccessful
#define ICDREQUESTDELETEDATABASE_STATUSCODE_DBNOTFOUND  404



@interface ICDRequestDeleteDatabase ()

@property (strong, nonatomic) NSString *dbName;
@property (strong, nonatomic) NSString *path;
@property (strong, nonatomic) NSArray *responseDescriptors;

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
        NSCharacterSet *whiteSpacesAndNewLines = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        NSString *trimmedDBName = (dbName ? [dbName stringByTrimmingCharactersInSet:whiteSpacesAndNewLines] : nil);
        
        if (!trimmedDBName || ([trimmedDBName length] == 0))
        {
            self = nil;
        }
        else
        {
            _dbName = trimmedDBName;
            _path = [NSString stringWithFormat:ICDREQUESTDELETEDATABASE_PATH_FORMAT, _dbName];
            _responseDescriptors = [ICDRequestDeleteDatabase responseDescriptorsWithPath:_path];
        }
    }
    
    return self;
}


#pragma mark - ICDRequestProtocol methods
- (void)asynExecuteRequestWithObjectManager:(id)objectManager
                          completionHandler:(ICDRequestProtocolCompletionHandlerBlockType)completionHandler
{
    RKObjectManager *thisObjectManager = (RKObjectManager *)objectManager;
    NSArray *thisResponseDescriptors = self.responseDescriptors;
    
    // Add configuration
    [thisObjectManager addResponseDescriptorsFromArray:thisResponseDescriptors];
    
    // Execute request
    __weak ICDRequestDeleteDatabase *weakSelf = self;
    
    void (^successBlock)(RKObjectRequestOperation *op, RKMappingResult *mapResult) = ^(RKObjectRequestOperation *op, RKMappingResult *mapResult)
    {
        // Remove configuration
        [thisObjectManager removeResponseDescriptorsFromArray:thisResponseDescriptors];
        
        // Notify
        __strong ICDRequestDeleteDatabase *strongSelf = weakSelf;
        if (strongSelf && strongSelf.delegate)
        {
            [strongSelf.delegate requestDeleteDatabase:strongSelf didDeleteDatabaseWithName:strongSelf.dbName];
        }
        
        // Finish execution
        if (completionHandler)
        {
            completionHandler();
        }
    };
    
    void (^failureBlock)(RKObjectRequestOperation *op, NSError *err) = ^(RKObjectRequestOperation *op, NSError *err)
    {
        // Remove configuration
        [thisObjectManager removeResponseDescriptorsFromArray:thisResponseDescriptors];
        
        // Notify
        __strong ICDRequestDeleteDatabase *strongSelf = weakSelf;
        if (strongSelf && strongSelf.delegate)
        {
            [strongSelf.delegate requestDeleteDatabase:strongSelf didFailWithError:err];
        }
        
        // Finish execution
        if (completionHandler)
        {
            completionHandler();
        }
    };
    
    [thisObjectManager deleteObject:nil path:self.path parameters:nil success:successBlock failure:failureBlock];
}


#pragma mark - Private class methods
+ (NSArray *)responseDescriptorsWithPath:(NSString *)path
{
    return @[[ICDRequestDeleteDatabase responseDescriptorForSuccessWithPath:path],
             [ICDRequestDeleteDatabase responseDescriptorForDatabaseNotFoundWithPath:path]];
}

+ (RKResponseDescriptor *)responseDescriptorForSuccessWithPath:(NSString *)path
{
    // Mapping
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[ICDRequestResponseValueOk class]];
    [mapping addAttributeMappingsFromArray:@[ICDREQUESTRESPONSEVALUE_PROPERTY_KEY_OK]];
    
    // Status code
    NSIndexSet *statusCodes = [NSIndexSet indexSetWithIndex:ICDREQUESTDELETEDATABASE_STATUSCODE_SUCCESS];
    
    // Response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping
                                                                                            method:RKRequestMethodDELETE
                                                                                       pathPattern:path
                                                                                           keyPath:nil
                                                                                       statusCodes:statusCodes];
    
    return responseDescriptor;
}

+ (RKResponseDescriptor *)responseDescriptorForDatabaseNotFoundWithPath:(NSString *)path
{
    // Mapping
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[ICDRequestResponseValueError class]];
    [mapping addAttributeMappingsFromArray:@[ICDREQUESTRESPONSEVALUEERROR_PROPERTY_KEY_ERROR,
                                             ICDREQUESTRESPONSEVALUEERROR_PROPERTY_KEY_REASON]];
    
    // Status code
    NSIndexSet *statusCodes = [NSIndexSet indexSetWithIndex:ICDREQUESTDELETEDATABASE_STATUSCODE_DBNOTFOUND];
    
    // Response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping
                                                                                            method:RKRequestMethodDELETE
                                                                                       pathPattern:path
                                                                                           keyPath:nil
                                                                                       statusCodes:statusCodes];
    
    return responseDescriptor;
}

@end
