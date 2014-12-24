//
//  ICDRequestDocument.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 23/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import <RestKit/RestKit.h>
#import <JSONSyntaxHighlight/JSONSyntaxHighlight.h>

#import "ICDRequestDocument.h"

#import "ICDLog.h"



#define ICDREQUESTDOCUMENT_PATH_FORMAT  @"/%@/%@"

#define ICDREQUESTDOCUMENT_DOCDICTIONARY_PROPERTY_KEY_DIC   @"dictionary"



@interface ICDRequestDocumentDictionary : NSObject

@property (strong, nonatomic) NSDictionary *dictionary;

@end



@interface ICDRequestDocument ()

@property (strong, nonatomic) NSString *path;
@property (strong, nonatomic) RKResponseDescriptor *responseDescriptor;

@end



@implementation ICDRequestDocument

#pragma mark - Init object
- (id)init
{
    return [self initWithDatabaseName:nil documentId:nil];
}

- (id)initWithDatabaseName:(NSString *)dbName documentId:(NSString *)documentId
{
    self = [super init];
    if (self)
    {
        if (!dbName || !documentId)
        {
            self = nil;
        }
        else
        {
            _path = [NSString stringWithFormat:ICDREQUESTDOCUMENT_PATH_FORMAT, dbName, documentId];
            _responseDescriptor = [ICDRequestDocument responseDescriptorForPath:_path];
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
    __weak ICDRequestDocument *weakSelf = self;
    
    void (^successBlock)(RKObjectRequestOperation *op, RKMappingResult *mapResult) = ^(RKObjectRequestOperation *op, RKMappingResult *mapResult)
    {
        // Remove configuration
        [thisObjectManager removeResponseDescriptor:thisResponseDescriptor];
        
        // Notify
        __strong ICDRequestDocument *strongSelf = weakSelf;
        if (strongSelf)
        {
            ICDRequestDocumentDictionary *docDictionary = (ICDRequestDocumentDictionary *)[mapResult firstObject];
            
            [strongSelf notifySuccessWithDocumentDictionary:docDictionary];
        }
    };
    
    void (^failureBlock)(RKObjectRequestOperation *op, NSError *err) = ^(RKObjectRequestOperation *op, NSError *err)
    {
        // Remove configuration
        [thisObjectManager removeResponseDescriptor:thisResponseDescriptor];
        
        // Notify
        __strong ICDRequestDocument *strongSelf = weakSelf;
        if (strongSelf)
        {
            [strongSelf notifyFailureWithError:err];
        }
    };
    
    [thisObjectManager getObject:nil path:self.path parameters:nil success:successBlock failure:failureBlock];
}


#pragma mark - Private methods
- (void)notifySuccessWithDocumentDictionary:(ICDRequestDocumentDictionary *)docDictionary
{
    if (self.delegate)
    {
        JSONSyntaxHighlight *jsh = [[JSONSyntaxHighlight alloc] initWithJSON:docDictionary.dictionary];
        NSAttributedString *highlightJSON = [jsh highlightJSON];
        
        [self.delegate requestDocument:self didGetDocument:highlightJSON];
    }
}

- (void)notifyFailureWithError:(NSError *)err
{
    if (self.delegate)
    {
        [self.delegate requestDocument:self didFailWithError:err];
    }
}


#pragma mark - Private class methods
+ (RKResponseDescriptor *)responseDescriptorForPath:(NSString *)path
{
    // Mapping
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[ICDRequestDocumentDictionary class]];
    [mapping addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:nil
                                                                      toKeyPath:ICDREQUESTDOCUMENT_DOCDICTIONARY_PROPERTY_KEY_DIC]];
    
    // Status code
    NSIndexSet *statusCodes = [NSIndexSet indexSetWithIndex:RKStatusCodeClassSuccessful];
    
    // Response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping
                                                                                            method:RKRequestMethodGET
                                                                                       pathPattern:path
                                                                                           keyPath:nil
                                                                                       statusCodes:statusCodes];
    
    return responseDescriptor;
}

@end



@implementation ICDRequestDocumentDictionary

@end
