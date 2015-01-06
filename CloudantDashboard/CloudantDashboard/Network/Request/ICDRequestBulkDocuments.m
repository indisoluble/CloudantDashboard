//
//  ICDRequestBulkDocuments.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 06/01/2015.
//  Copyright (c) 2015 Enrique de la Torre. All rights reserved.
//

#import <RestKit/RestKit.h>

#import "ICDRequestBulkDocuments.h"

#import "ICDModelDocument.h"

#import "ICDLog.h"



#define ICDREQUESTBULKDOCUMENTS_PATH_FORMAT @"/%@/_bulk_docs"

#define ICDREQUESTBULKDOCUMENTS_PARAMETER_KEY_DOCS  @"docs"

#define ICDREQUESTBULKDOCUMENTS_NUMBEROFDOCS    100

#define ICDREQUESTBULKDOCUMENTS_STATUSCODE_CREATED  201

#define ICDREQUESTBULKDOCUMENTS_JSON_KEY_ID     @"id"
#define ICDREQUESTBULKDOCUMENTS_JSON_KEY_REV    @"rev"



@interface ICDRequestBulkDocuments ()

@property (strong, nonatomic) NSString *path;
@property (strong, nonatomic) NSDictionary *parameters;
@property (strong, nonatomic) RKResponseDescriptor *responseDescriptor;

@end



@implementation ICDRequestBulkDocuments

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
            NSArray *docs = [ICDRequestBulkDocuments arrayWithObject:@{} times:ICDREQUESTBULKDOCUMENTS_NUMBEROFDOCS];
            
            _path = [NSString stringWithFormat:ICDREQUESTBULKDOCUMENTS_PATH_FORMAT, trimmedDBName];
            _parameters = @{ICDREQUESTBULKDOCUMENTS_PARAMETER_KEY_DOCS: docs};
            _responseDescriptor = [ICDRequestBulkDocuments responseDescriptorForSuccessWithPath:_path];
        }
    }
    
    return self;
}


#pragma mark - ICDRequestProtocol methods
- (void)asynExecuteRequestWithObjectManager:(id)objectManager
                          completionHandler:(ICDRequestProtocolCompletionHandlerBlockType)completionHandler
{
    RKObjectManager *thisObjectManager = (RKObjectManager *)objectManager;
    RKResponseDescriptor *thisResponseDescriptor = self.responseDescriptor;
    
    // Add configuration
    [thisObjectManager addResponseDescriptor:thisResponseDescriptor];
    
    // Execute request
    __weak ICDRequestBulkDocuments *weakSelf = self;
    
    void (^successBlock)(RKObjectRequestOperation *op, RKMappingResult *mapResult) = ^(RKObjectRequestOperation *op, RKMappingResult *mapResult)
    {
        // Remove configuration
        [thisObjectManager removeResponseDescriptor:thisResponseDescriptor];
        
        // Notify
        NSArray *documents = [mapResult array];
        ICDLogTrace(@"Created %lu documents. Last document %@", (unsigned long)[documents count], [documents lastObject]);
        
        __strong ICDRequestBulkDocuments *strongSelf = weakSelf;
        if (strongSelf && strongSelf.delegate)
        {
            [strongSelf.delegate requestBulkDocuments:strongSelf didBulkDocuments:documents];
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
        __strong ICDRequestBulkDocuments *strongSelf = weakSelf;
        if (strongSelf && strongSelf.delegate)
        {
            [strongSelf.delegate requestBulkDocuments:strongSelf didFailWithError:err];
        }
        
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
    [mapping addAttributeMappingsFromDictionary:@{ICDREQUESTBULKDOCUMENTS_JSON_KEY_ID: ICDMODELDOCUMENT_PROPERTY_KEY_ID,
                                                  ICDREQUESTBULKDOCUMENTS_JSON_KEY_REV: ICDMODELDOCUMENT_PROPERTY_KEY_REV}];
    
    // Status code
    NSIndexSet *statusCodes = [NSIndexSet indexSetWithIndex:ICDREQUESTBULKDOCUMENTS_STATUSCODE_CREATED];
    
    // Response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:path
                                                                                           keyPath:nil
                                                                                       statusCodes:statusCodes];
    
    return responseDescriptor;
}

+ (NSArray *)arrayWithObject:(id)object times:(NSUInteger)times
{
    id array[times];
    for (NSUInteger index = 0; index < times; index++)
    {
        array[index] = object;
    }
    
    return [NSArray arrayWithObjects:array count:times];
}

@end
