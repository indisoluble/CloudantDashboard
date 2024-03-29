//
//  ICDRequestAddRevision.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 28/12/2014.
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

#import "ICDRequestAddRevision.h"

#import "ICDModelDocument.h"

#import "ICDLog.h"

#import "NSDictionary+CloudantSpecialKeys.h"



#define ICDREQUESTADDREVISION_PATH_FORMAT   @"/%@"

#define ICDREQUESTADDREVISION_STATUSCODE_CREATED            201
#define ICDREQUESTADDREVISION_STATUSCODE_ACCEPTEDFORWRITING 202

#define ICDREQUESTADDREVISION_JSON_KEY_ID   @"id"
#define ICDREQUESTADDREVISION_JSON_KEY_REV  @"rev"



@interface ICDRequestAddRevision ()

@property (strong, nonatomic, readonly) ICDRequestAddRevisionNotification *notification;

@property (strong, nonatomic) NSString *dbName;
@property (strong, nonatomic) NSString *docId;

@property (strong, nonatomic) NSString *path;
@property (strong, nonatomic) NSMutableDictionary *parameters;

@end



@implementation ICDRequestAddRevision

#pragma mark - Init object
- (id)init
{
    return [self initWithDatabaseName:nil documentId:nil documentRev:nil documentData:nil];
}

- (id)initWithDatabaseName:(NSString *)dbName
                documentId:(NSString *)docId
               documentRev:(NSString *)docRev
              documentData:(NSDictionary *)docData
{
    return [self initWithDatabaseName:dbName documentId:docId documentRev:docRev documentData:docData notification:nil];
}

- (id)initWithDatabaseName:(NSString *)dbName
                documentId:(NSString *)docId
               documentRev:(NSString *)docRev
              documentData:(NSDictionary *)docData
              notification:(ICDRequestAddRevisionNotification *)notificationOrNil
{
    self = [super init];
    if (self)
    {
        NSCharacterSet *whiteSpacesAndNewLines = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        
        NSString *trimmedDBName = (dbName ? [dbName stringByTrimmingCharactersInSet:whiteSpacesAndNewLines] : nil);
        NSString *trimmedDocId = (docId ? [docId stringByTrimmingCharactersInSet:whiteSpacesAndNewLines] : nil);
        NSString *trimmedDocRev = (docRev ? [docRev stringByTrimmingCharactersInSet:whiteSpacesAndNewLines] : nil);
        
        if (!trimmedDBName || ([trimmedDBName length] == 0) ||
            !trimmedDocId || ([trimmedDocId length] == 0) ||
            !trimmedDocRev || ([trimmedDocRev length] == 0) ||
            !docData || [docData containAnyCloudantSpecialKeys])
        {
            self = nil;
        }
        else
        {
            _dbName = trimmedDBName;
            _docId = trimmedDocId;
            
            _path = [NSString stringWithFormat:ICDREQUESTADDREVISION_PATH_FORMAT, _dbName];
            
            _parameters = [NSMutableDictionary dictionaryWithDictionary:docData];
            [_parameters setObject:_docId forKey:kNSDictionaryCloudantSpecialKeysDocumentId];
            [_parameters setObject:trimmedDocRev forKey:kNSDictionaryCloudantSpecialKeysDocumentRev];
            
            _notification = (notificationOrNil ? notificationOrNil : [ICDRequestAddRevisionNotification sharedInstance]);
        }
    }
    
    return self;
}


#pragma mark - ICDRequestProtocol methods
- (void)asynExecuteRequestWithObjectManager:(id)objectManager
                          completionHandler:(ICDRequestProtocolCompletionHandlerBlockType)completionHandler
{
    RKObjectManager *thisObjectManager = (RKObjectManager *)objectManager;
    RKResponseDescriptor *thisResponseDescriptor = [ICDRequestAddRevision responseDescriptorForSuccessWithPath:self.path];
    
    NSString *thisDBName = self.dbName;
    NSString *thisDocId = self.docId;
    ICDRequestAddRevisionNotification *thisNotification = self.notification;
    
    // Add configuration
    [thisObjectManager addResponseDescriptor:thisResponseDescriptor];
    
    // Execute request
    __weak ICDRequestAddRevision *weakSelf = self;
    
    void (^successBlock)(RKObjectRequestOperation *op, RKMappingResult *mapResult) = ^(RKObjectRequestOperation *op, RKMappingResult *mapResult)
    {
        // Remove configuration
        [thisObjectManager removeResponseDescriptor:thisResponseDescriptor];
        
        // Notify
        ICDModelDocument *revision = (ICDModelDocument *)[mapResult firstObject];
        ICDLogTrace(@"Revision added: %@", revision);
        
        __strong ICDRequestAddRevision *strongSelf = weakSelf;
        if (strongSelf && strongSelf.delegate)
        {
            [strongSelf.delegate requestAddRevision:strongSelf didAddRevision:revision];
        }
        
        [thisNotification postDidAddRevisionNotificationWithDatabaseName:thisDBName revision:revision];
        
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
        __strong ICDRequestAddRevision *strongSelf = weakSelf;
        if (strongSelf && strongSelf.delegate)
        {
            [strongSelf.delegate requestAddRevision:strongSelf didFailWithError:err];
        }
        
        [thisNotification postDidFailNotificationWithDatabaseName:thisDBName documentId:thisDocId error:err];
        
        // Finish execution
        if (completionHandler)
        {
            completionHandler();
        }
    };
    
    [thisObjectManager postObject:nil path:self.path parameters:self.parameters success:successBlock failure:failureBlock];
}


#pragma mark - Private class methods
+ (RKResponseDescriptor *)responseDescriptorForSuccessWithPath:(NSString *)path
{
    // Mapping
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[ICDModelDocument class]];
    [mapping addAttributeMappingsFromDictionary:@{ICDREQUESTADDREVISION_JSON_KEY_ID: ICDMODELDOCUMENT_PROPERTY_KEY_ID,
                                                  ICDREQUESTADDREVISION_JSON_KEY_REV: ICDMODELDOCUMENT_PROPERTY_KEY_REV}];
    
    // Status code
    NSMutableIndexSet *statusCodes = [NSMutableIndexSet indexSetWithIndex:ICDREQUESTADDREVISION_STATUSCODE_CREATED];
    [statusCodes addIndex:ICDREQUESTADDREVISION_STATUSCODE_ACCEPTEDFORWRITING];
    
    // Response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:path
                                                                                           keyPath:nil
                                                                                       statusCodes:statusCodes];
    
    return responseDescriptor;
}

@end
