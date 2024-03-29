//
//  ICDRequestAllDocuments.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 23/12/2014.
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

#import "ICDRequestAllDocuments.h"

#import "ICDModelDocument.h"

#import "ICDLog.h"

#import "NSObject+ICDShallowDictionary.h"



#define ICDREQUESTALLDOCUMENTS_JSON_DOCUMENT_KEY_ID     @"id"
#define ICDREQUESTALLDOCUMENTS_JSON_DOCUMENT_KEY_REV    @"value.rev"

#define ICDREQUESTALLDOCUMENTS_PATH_FORMAT  @"/%@/_all_docs"
#define ICDREQUESTALLDOCUMENTS_KEYPATH      @"rows"



@interface ICDRequestAllDocuments ()

@property (strong, nonatomic) NSString *dbName;

@property (strong, nonatomic) NSString *path;
@property (strong, nonatomic) NSDictionary *parameters;

@end



@implementation ICDRequestAllDocuments

#pragma mark - Init object
- (id)init
{
    return [self initWithDatabaseName:nil arguments:nil];
}

- (id)initWithDatabaseName:(NSString *)dbName
                 arguments:(ICDRequestAllDocumentsArguments *)argumentsOrNil
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
            
            _path = [NSString stringWithFormat:ICDREQUESTALLDOCUMENTS_PATH_FORMAT, _dbName];
            _parameters = (argumentsOrNil ? [argumentsOrNil icdShallowDictionary] : nil);
        }
    }
    
    return self;
}


#pragma mark - ICDRequestProtocol methods
- (void)asynExecuteRequestWithObjectManager:(id)objectManager
                          completionHandler:(ICDRequestProtocolCompletionHandlerBlockType)completionHandler
{
    RKObjectManager *thisObjectManager = (RKObjectManager *)objectManager;
    RKResponseDescriptor *thisResponseDescriptor = [ICDRequestAllDocuments responseDescriptorForPath:self.path];
    
    NSString *thisDBName = self.dbName;
    
    // Add configuration
    [thisObjectManager addResponseDescriptor:thisResponseDescriptor];
    
    // Execute request
    __weak ICDRequestAllDocuments *weakSelf = self;
    
    void (^successBlock)(RKObjectRequestOperation *op, RKMappingResult *mapResult) = ^(RKObjectRequestOperation *op, RKMappingResult *mapResult)
    {
        // Remove configuration
        [thisObjectManager removeResponseDescriptor:thisResponseDescriptor];
        
        // Notify
        ICDLogTrace(@"Found %lu documents in %@", (unsigned long)[mapResult.array count], thisDBName);
        
        __strong ICDRequestAllDocuments *strongSelf = weakSelf;
        if (strongSelf && strongSelf.delegate)
        {
            [strongSelf.delegate requestAllDocuments:strongSelf didGetDocuments:mapResult.array];
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
        [thisObjectManager removeResponseDescriptor:thisResponseDescriptor];
        
        // Notify
        __strong ICDRequestAllDocuments *strongSelf = weakSelf;
        if (strongSelf && strongSelf.delegate)
        {
            [strongSelf.delegate requestAllDocuments:strongSelf didFailWithError:err];
        }
        
        // Finish execution
        if (completionHandler)
        {
            completionHandler();
        }
    };
    
    [thisObjectManager getObjectsAtPath:self.path parameters:self.parameters success:successBlock failure:failureBlock];
}


#pragma mark - Private class methods
+ (RKResponseDescriptor *)responseDescriptorForPath:(NSString *)path
{
    // Mapping
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[ICDModelDocument class]];
    [mapping addAttributeMappingsFromDictionary:@{ICDREQUESTALLDOCUMENTS_JSON_DOCUMENT_KEY_ID: ICDMODELDOCUMENT_PROPERTY_KEY_ID,
                                                  ICDREQUESTALLDOCUMENTS_JSON_DOCUMENT_KEY_REV: ICDMODELDOCUMENT_PROPERTY_KEY_REV}];
    
    // Status code
    NSIndexSet *statusCodes = [NSIndexSet indexSetWithIndex:RKStatusCodeClassSuccessful];
    
    // Response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping
                                                                                            method:RKRequestMethodGET
                                                                                       pathPattern:path
                                                                                           keyPath:ICDREQUESTALLDOCUMENTS_KEYPATH
                                                                                       statusCodes:statusCodes];
    
    return responseDescriptor;
}

@end
