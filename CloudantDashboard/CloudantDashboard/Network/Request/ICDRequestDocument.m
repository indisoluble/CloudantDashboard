//
//  ICDRequestDocument.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 23/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import <RestKit/RestKit.h>

#import "ICDRequestDocument.h"
#import "ICDRequestResponseValueDictionary.h"

#import "ICDLog.h"



#define ICDREQUESTDOCUMENT_PATH_FORMAT  @"/%@/%@"



@interface ICDRequestDocument ()

@property (strong, nonatomic) NSString *dbName;
@property (strong, nonatomic) NSString *documentId;

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
        NSCharacterSet *whiteSpacesAndNewLines = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        
        NSString *trimmedDBName = (dbName ? [dbName stringByTrimmingCharactersInSet:whiteSpacesAndNewLines] : nil);
        NSString *trimmedDocId = (documentId ? [documentId stringByTrimmingCharactersInSet:whiteSpacesAndNewLines] : nil);
        
        if (!trimmedDBName || !trimmedDocId || ([trimmedDBName length] == 0) || ([trimmedDocId length] == 0))
        {
            self = nil;
        }
        else
        {
            _dbName = trimmedDBName;
            _documentId = trimmedDocId;
            
            _path = [NSString stringWithFormat:ICDREQUESTDOCUMENT_PATH_FORMAT, _dbName, _documentId];
            _responseDescriptor = [ICDRequestDocument responseDescriptorForPath:_path];
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
    
    NSString *thisDBName = self.dbName;
    NSString *thisDocumentId = self.documentId;
    
    // Add configuration
    [thisObjectManager addResponseDescriptor:thisResponseDescriptor];
    
    // Execute request
    __weak ICDRequestDocument *weakSelf = self;
    
    void (^successBlock)(RKObjectRequestOperation *op, RKMappingResult *mapResult) = ^(RKObjectRequestOperation *op, RKMappingResult *mapResult)
    {
        // Remove configuration
        [thisObjectManager removeResponseDescriptor:thisResponseDescriptor];
        
        // Notify
        ICDLogTrace(@"Found document %@ in %@", thisDocumentId, thisDBName);
        
        __strong ICDRequestDocument *strongSelf = weakSelf;
        if (strongSelf)
        {
            ICDRequestResponseValueDictionary *docDictionary = (ICDRequestResponseValueDictionary *)[mapResult firstObject];
            
            [strongSelf notifySuccessWithDocumentDictionary:docDictionary];
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
        __strong ICDRequestDocument *strongSelf = weakSelf;
        if (strongSelf)
        {
            [strongSelf notifyFailureWithError:err];
        }
        
        // Finish execution
        if (completionHandler)
        {
            completionHandler();
        }
    };
    
    [thisObjectManager getObject:nil path:self.path parameters:nil success:successBlock failure:failureBlock];
}


#pragma mark - Private methods
- (void)notifySuccessWithDocumentDictionary:(ICDRequestResponseValueDictionary *)docDictionary
{
    if (self.delegate)
    {
        [self.delegate requestDocument:self didGetDocument:docDictionary.dictionary];
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
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[ICDRequestResponseValueDictionary class]];
    [mapping addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:nil
                                                                      toKeyPath:ICDREQUESTRESPONSEVALUEDICTIONARY_PROPERTY_KEY_DIC]];
    
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
