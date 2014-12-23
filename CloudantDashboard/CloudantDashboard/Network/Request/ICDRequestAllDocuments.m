//
//  ICDRequestAllDocuments.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 23/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import <RestKit/RestKit.h>

#import "ICDRequestAllDocuments.h"

#import "ICDModelDocument.h"



#define ICDREQUESTALLDOCUMENTS_JSON_DOCUMENT_KEY_ID     @"id"
#define ICDREQUESTALLDOCUMENTS_JSON_DOCUMENT_KEY_REV    @"value.rev"

#define ICDREQUESTALLDOCUMENTS_METHOD       @"_all_docs"
#define ICDREQUESTALLDOCUMENTS_PATHPATTERN  [@"/:databaseName/" stringByAppendingString:ICDREQUESTALLDOCUMENTS_METHOD]
#define ICDREQUESTALLDOCUMENTS_KEYPATH      @"rows"



@interface ICDRequestAllDocuments ()

@property (strong, nonatomic) NSString *path;

@end



@implementation ICDRequestAllDocuments

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
            _path = [NSString stringWithFormat:@"/%@/%@", dbName, ICDREQUESTALLDOCUMENTS_METHOD];
        }
    }
    
    return self;
}


#pragma mark - ICDRequestProtocol methods
- (void)executeRequestWithObjectManager:(id)objectManager
{
    __weak ICDRequestAllDocuments *weakSelf = self;
    
    void (^successBlock)(RKObjectRequestOperation *op, RKMappingResult *mapResult) = ^(RKObjectRequestOperation *op, RKMappingResult *mapResult)
    {
        __strong ICDRequestAllDocuments *strongSelf = weakSelf;
        if (strongSelf && strongSelf.delegate)
        {
            [strongSelf.delegate requestAllDocuments:strongSelf didGetDocuments:mapResult.array];
        }
    };
    
    void (^failureBlock)(RKObjectRequestOperation *op, NSError *err) = ^(RKObjectRequestOperation *op, NSError *err)
    {
        __strong ICDRequestAllDocuments *strongSelf = weakSelf;
        if (strongSelf && strongSelf.delegate)
        {
            [strongSelf.delegate requestAllDocuments:strongSelf didFailWithError:err];
        }
    };
    
    RKObjectManager *thisObjectManager = (RKObjectManager *)objectManager;
    
    [thisObjectManager getObjectsAtPath:self.path
                             parameters:nil
                                success:successBlock
                                failure:failureBlock];
}

+ (void)configureObjectManager:(id)objectManager
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
                                                                                       pathPattern:ICDREQUESTALLDOCUMENTS_PATHPATTERN
                                                                                           keyPath:ICDREQUESTALLDOCUMENTS_KEYPATH
                                                                                       statusCodes:statusCodes];
    
    // Configure
    [(RKObjectManager *)objectManager addResponseDescriptor:responseDescriptor];
}

@end
