//
//  ICDRequestDesignDoc.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 20/01/2015.
//  Copyright (c) 2015 Enrique de la Torre. All rights reserved.
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

#import "ICDRequestDesignDoc.h"

#import "ICDModelDesignDocument.h"
#import "ICDModelDesignDocumentView.h"

#import "ICDLog.h"

#import "NSString+CloudantDesignDocId.h"



#define ICDREQUESTDESIGNDOC_PATH_FORMAT @"/%@/%@"

#define ICDREQUESTDESIGNDOC_JSON_DESIGNDOC_KEY_ID       @"_id"
#define ICDREQUESTDESIGNDOC_JSON_DESIGNDOC_KEY_REV      @"_rev"
#define ICDREQUESTDESIGNDOC_JSON_DESIGNDOC_KEY_LANGUAGE @"language"
#define ICDREQUESTDESIGNDOC_JSON_DESIGNDOC_KEY_VIEWS    @"views"



@interface ICDRequestDesignDoc ()

@property (strong, nonatomic) NSString *dbName;
@property (strong, nonatomic) NSString *designDocId;

@property (strong, nonatomic) NSString *path;

@end



@implementation ICDRequestDesignDoc

#pragma mark - Init object
- (id)init
{
    return [self initWithDatabaseName:nil designDocId:nil];
}

- (id)initWithDatabaseName:(NSString *)dbName designDocId:(NSString *)designDocId
{
    self = [super init];
    if (self)
    {
        NSCharacterSet *whiteSpacesAndNewLines = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        
        NSString *trimmedDBName = (dbName ? [dbName stringByTrimmingCharactersInSet:whiteSpacesAndNewLines] : nil);
        NSString *trimmedDesignDocId = (designDocId ? [designDocId stringByTrimmingCharactersInSet:whiteSpacesAndNewLines] : nil);
        
        if (!trimmedDBName ||
            !trimmedDesignDocId ||
            ([trimmedDBName length] == 0) ||
            ![trimmedDesignDocId isDesignDocId])
        {
            self = nil;
        }
        else
        {
            _dbName = trimmedDBName;
            _designDocId = trimmedDesignDocId;
            
            _path = [NSString stringWithFormat:ICDREQUESTDESIGNDOC_PATH_FORMAT, _dbName, _designDocId];
        }
    }
    
    return self;
}


#pragma mark - ICDRequestProtocol methods
- (void)asynExecuteRequestWithObjectManager:(id)objectManager
                          completionHandler:(ICDRequestProtocolCompletionHandlerBlockType)completionHandler
{
    RKObjectManager *thisObjectManager = (RKObjectManager *)objectManager;
    RKResponseDescriptor *thisResponseDescriptor = [ICDRequestDesignDoc responseDescriptorForPath:self.path];
    
    NSString *thisDBName = self.dbName;
    NSString *thisDesignDocId = self.designDocId;
    
    // Add configuration
    [thisObjectManager addResponseDescriptor:thisResponseDescriptor];
    
    // Execute request
    __weak ICDRequestDesignDoc *weakSelf = self;
    
    void (^successBlock)(RKObjectRequestOperation *op, RKMappingResult *mapResult) = ^(RKObjectRequestOperation *op, RKMappingResult *mapResult)
    {
        // Remove configuration
        [thisObjectManager removeResponseDescriptor:thisResponseDescriptor];
        
        // Notify
        ICDLogTrace(@"Found document %@ in %@", thisDesignDocId, thisDBName);
        
        __strong ICDRequestDesignDoc *strongSelf = weakSelf;
        if (strongSelf && strongSelf.delegate)
        {
            ICDModelDesignDocument *designDoc = (ICDModelDesignDocument *)[mapResult firstObject];
            
            [strongSelf.delegate requestDesignDoc:strongSelf didGetDesignDoc:designDoc];
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
        __strong ICDRequestDesignDoc *strongSelf = weakSelf;
        if (strongSelf && strongSelf.delegate)
        {
            [strongSelf.delegate requestDesignDoc:strongSelf didFailWithError:err];
        }
        
        // Finish execution
        if (completionHandler)
        {
            completionHandler();
        }
    };
    
    [thisObjectManager getObject:nil path:self.path parameters:nil success:successBlock failure:failureBlock];
}


#pragma mark - Private class methods
+ (RKResponseDescriptor *)responseDescriptorForPath:(NSString *)path
{
    // Mapping
    RKObjectMapping *viewMapping = [RKObjectMapping mappingForClass:[ICDModelDesignDocumentView class]];
    viewMapping.forceCollectionMapping = YES; // RestKit cannot infer this is a collection, so we force it
    [viewMapping addAttributeMappingFromKeyOfRepresentationToAttribute:ICDMODELDESIGNDOCUMENTVIEW_PROPERTY_KEY_VIEWNAME];
    
    RKObjectMapping *designDocMapping = [RKObjectMapping mappingForClass:[ICDModelDesignDocument class]];
    [designDocMapping addAttributeMappingsFromDictionary:@{ICDREQUESTDESIGNDOC_JSON_DESIGNDOC_KEY_ID: ICDMODELDOCUMENT_PROPERTY_KEY_ID,
                                                           ICDREQUESTDESIGNDOC_JSON_DESIGNDOC_KEY_REV: ICDMODELDOCUMENT_PROPERTY_KEY_REV,
                                                           ICDREQUESTDESIGNDOC_JSON_DESIGNDOC_KEY_LANGUAGE: ICDMODELDESIGNDOCUMENT_PROPERTY_KEY_LANGUAGE}];
    [designDocMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:ICDREQUESTDESIGNDOC_JSON_DESIGNDOC_KEY_VIEWS
                                                                                     toKeyPath:ICDMODELDESIGNDOCUMENT_PROPERTY_KEY_VIEWS
                                                                                   withMapping:viewMapping]];
    
    // Status code
    NSIndexSet *statusCodes = [NSIndexSet indexSetWithIndex:RKStatusCodeClassSuccessful];
    
    // Response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:designDocMapping
                                                                                            method:RKRequestMethodGET
                                                                                       pathPattern:path
                                                                                           keyPath:nil
                                                                                       statusCodes:statusCodes];
    
    return responseDescriptor;
}

@end
