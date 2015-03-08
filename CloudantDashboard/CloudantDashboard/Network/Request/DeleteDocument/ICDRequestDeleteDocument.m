//
//  ICDRequestDeleteDocument.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 26/12/2014.
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

#import "ICDRequestDeleteDocument.h"

#import "ICDModelDocument.h"
#import "ICDRequestResponseValueError.h"

#import "ICDLog.h"

#import "RKObjectManager+Helper.h"



#define ICDREQUESTDELETEDOCUMENT_PATH_FORMAT    @"/%@/%@"

#define ICDREQUESTDELETEDOCUMENT_PARAMETER_KEY_REV  @"rev"

#define ICDREQUESTDELETEDOCUMENT_STATUSCODE_SUCCESS     RKStatusCodeClassSuccessful
#define ICDREQUESTDELETEDOCUMENT_STATUSCODE_REVINVALID  409

#define ICDREQUESTDELETEDOCUMENT_JSON_KEY_ID    @"id"
#define ICDREQUESTDELETEDOCUMENT_JSON_KEY_REV   @"rev"



@interface ICDRequestDeleteDocument ()

@property (strong, nonatomic) NSString *documentId;
@property (strong, nonatomic) NSString *documentRev;

@property (strong, nonatomic) NSString *path;
@property (strong, nonatomic) NSDictionary *parameters;

@end



@implementation ICDRequestDeleteDocument

#pragma mark - Init object
- (id)init
{
    return [self initWithDatabaseName:nil documentId:nil documentRev:nil];
}

- (id)initWithDatabaseName:(NSString *)dbName
                documentId:(NSString *)documentId
               documentRev:(NSString *)documentRev
{
    self = [super init];
    if (self)
    {
        NSCharacterSet *whiteSpacesAndNewLines = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        NSString *trimmedDBName = (dbName ? [dbName stringByTrimmingCharactersInSet:whiteSpacesAndNewLines] : nil);
        NSString *trimmedDocId = (documentId ? [documentId stringByTrimmingCharactersInSet:whiteSpacesAndNewLines] : nil);
        NSString *trimmedDocRev = (documentRev ? [documentRev stringByTrimmingCharactersInSet:whiteSpacesAndNewLines] : nil);
        
        if (!trimmedDBName || ([trimmedDBName length] == 0) ||
            !trimmedDocId || ([trimmedDocId length] == 0) ||
            !trimmedDocRev || ([trimmedDocRev length] == 0))
        {
            self = nil;
        }
        else
        {
            _documentId = trimmedDocId;
            _documentRev = trimmedDocRev;
            
            _path = [NSString stringWithFormat:ICDREQUESTDELETEDOCUMENT_PATH_FORMAT, trimmedDBName, _documentId];
            _parameters = @{ICDREQUESTDELETEDOCUMENT_PARAMETER_KEY_REV: _documentRev};
        }
    }
    
    return self;
}


#pragma mark - ICDRequestProtocol methods
- (void)asynExecuteRequestWithObjectManager:(id)objectManager
                          completionHandler:(ICDRequestProtocolCompletionHandlerBlockType)completionHandler
{
    RKObjectManager *thisObjectManager = (RKObjectManager *)objectManager;
    NSArray *thisResponseDescriptors = [ICDRequestDeleteDocument responseDescriptorsWithPath:self.path];
    
    NSString *thisDocumentId = self.documentId;
    NSString *thisDocumentRev = self.documentRev;
    
    // Add configuration
    [thisObjectManager addResponseDescriptorsFromArray:thisResponseDescriptors];
    
    // Execute request
    __weak ICDRequestDeleteDocument *weakSelf = self;
    
    void (^successBlock)(RKObjectRequestOperation *op, RKMappingResult *mapResult) = ^(RKObjectRequestOperation *op, RKMappingResult *mapResult)
    {
        // Remove configuration
        [thisObjectManager removeResponseDescriptorsFromArray:thisResponseDescriptors];
        
        // Notify
        ICDLogTrace(@"Deleted document <%@, %@>", thisDocumentId, thisDocumentRev);
        
        __strong ICDRequestDeleteDocument *strongSelf = weakSelf;
        if (strongSelf && strongSelf.delegate)
        {
            [strongSelf.delegate requestDeleteDocument:strongSelf
                               didDeleteDocumentWithId:thisDocumentId
                                              revision:thisDocumentRev];
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
        __strong ICDRequestDeleteDocument *strongSelf = weakSelf;
        if (strongSelf && strongSelf.delegate)
        {
            [strongSelf.delegate requestDeleteDocument:strongSelf didFailWithError:err];
        }
        
        // Finish execution
        if (completionHandler)
        {
            completionHandler();
        }
    };
    
    [thisObjectManager deleteObject:nil path:self.path parameters:self.parameters success:successBlock failure:failureBlock];
}


#pragma mark - Private class methods
+ (NSArray *)responseDescriptorsWithPath:(NSString *)path
{
    return @[[ICDRequestDeleteDocument responseDescriptorForSuccessWithPath:path],
             [ICDRequestDeleteDocument responseDescriptorForFailureWithPath:path]];
}

+ (RKResponseDescriptor *)responseDescriptorForSuccessWithPath:(NSString *)path
{
    // Mapping
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[ICDModelDocument class]];
    [mapping addAttributeMappingsFromDictionary:@{ICDREQUESTDELETEDOCUMENT_JSON_KEY_ID: ICDMODELDOCUMENT_PROPERTY_KEY_ID,
                                                  ICDREQUESTDELETEDOCUMENT_JSON_KEY_REV: ICDMODELDOCUMENT_PROPERTY_KEY_REV}];
    
    // Status code
    NSIndexSet *statusCodes = [NSIndexSet indexSetWithIndex:ICDREQUESTDELETEDOCUMENT_STATUSCODE_SUCCESS];
    
    // Response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping
                                                                                            method:RKRequestMethodDELETE
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
    NSIndexSet *statusCodes = [NSIndexSet indexSetWithIndex:ICDREQUESTDELETEDOCUMENT_STATUSCODE_REVINVALID];
    
    // Response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping
                                                                                            method:RKRequestMethodDELETE
                                                                                       pathPattern:path
                                                                                           keyPath:nil
                                                                                       statusCodes:statusCodes];
    
    return responseDescriptor;
}

@end
