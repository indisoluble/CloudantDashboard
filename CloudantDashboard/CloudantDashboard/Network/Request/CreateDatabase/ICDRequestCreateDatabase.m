//
//  ICDRequestCreateDatabase.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 25/12/2014.
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

#import <RestKit/RestKit.h>

#import "ICDRequestCreateDatabase.h"

#import "ICDRequestResponseValueOk.h"
#import "ICDRequestResponseValueError.h"

#import "ICDLog.h"

#import "RKObjectManager+Helper.h"



#define ICDREQUESTCREATEDATABASE_PATH_FORMAT    @"/%@"

#define ICDREQUESTCREATEDATABASE_STATUSCODE_CREATED                 201
#define ICDREQUESTCREATEDATABASE_STATUSCODE_CREATEDWITHOUTQUORUM    202
#define ICDREQUESTCREATEDATABASE_STATUSCODE_INVALIDNAME             RKStatusCodeClassClientError
#define ICDREQUESTCREATEDATABASE_STATUSCODE_ALREADYEXISTS           412



@interface ICDRequestCreateDatabase ()

@property (strong, nonatomic) NSString *dbName;
@property (strong, nonatomic) NSString *path;

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
        }
    }
    
    return self;
}


#pragma mark - ICDRequestProtocol methods
- (void)asynExecuteRequestWithObjectManager:(id)objectManager
                          completionHandler:(ICDRequestProtocolCompletionHandlerBlockType)completionHandler
{
    RKObjectManager *thisObjectManager = (RKObjectManager *)objectManager;
    NSArray *thisResponseDescriptors = [ICDRequestCreateDatabase responseDescriptorsWithPath:self.path];
    
    NSString *thisDBName = self.dbName;
    
    // Add configuration
    [thisObjectManager addResponseDescriptorsFromArray:thisResponseDescriptors];
    
    // Execute request
    __weak ICDRequestCreateDatabase *weakSelf = self;
    
    void (^successBlock)(RKObjectRequestOperation *op, RKMappingResult *mapResult) = ^(RKObjectRequestOperation *op, RKMappingResult *mapResult)
    {
        // Remove configuration
        [thisObjectManager removeResponseDescriptorsFromArray:thisResponseDescriptors];
        
        // Notify
        ICDLogTrace(@"Created database with name %@", thisDBName);
        
        __strong ICDRequestCreateDatabase *strongSelf = weakSelf;
        if (strongSelf && strongSelf.delegate)
        {
            [strongSelf.delegate requestCreateDatabase:strongSelf didCreateDatabaseWithName:thisDBName];
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
        __strong ICDRequestCreateDatabase *strongSelf = weakSelf;
        if (strongSelf && strongSelf.delegate)
        {
            [strongSelf.delegate requestCreateDatabase:strongSelf didFailWithError:err];
        }
        
        // Finish execution
        if (completionHandler)
        {
            completionHandler();
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
