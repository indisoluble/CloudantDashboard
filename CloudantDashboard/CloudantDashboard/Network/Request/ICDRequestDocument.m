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
#define ICDREQUESTDOCUMENT_PATHPATTERN  [NSString stringWithFormat:ICDREQUESTDOCUMENT_PATH_FORMAT, @":databaseName", @":documentId"]

#define ICDREQUESTDOCUMENT_DOCDICTIONARY_PROPERTY_KEY_DIC   @"dictionary"



@interface ICDRequestDocumentDictionary : NSObject

@property (strong, nonatomic) NSDictionary *dictionary;

@end



@interface ICDRequestDocument ()

@property (strong, nonatomic) NSString *path;

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
        }
    }
    
    return self;
}


#pragma mark - ICDRequestProtocol methods
- (void)executeRequestWithObjectManager:(id)objectManager
{
    __weak ICDRequestDocument *weakSelf = self;
    
    void (^successBlock)(RKObjectRequestOperation *op, RKMappingResult *mapResult) = ^(RKObjectRequestOperation *op, RKMappingResult *mapResult)
    {
        __strong ICDRequestDocument *strongSelf = weakSelf;
        if (strongSelf && strongSelf.delegate)
        {
            ICDRequestDocumentDictionary *docDictionary = (ICDRequestDocumentDictionary *)[mapResult firstObject];
            
            JSONSyntaxHighlight *jsh = [[JSONSyntaxHighlight alloc] initWithJSON:docDictionary.dictionary];
            NSAttributedString *highlightJSON = [jsh highlightJSON];
            
            [strongSelf.delegate requestDocument:strongSelf didGetDocument:highlightJSON];
        }
    };
    
    void (^failureBlock)(RKObjectRequestOperation *op, NSError *err) = ^(RKObjectRequestOperation *op, NSError *err)
    {
        __strong ICDRequestDocument *strongSelf = weakSelf;
        if (strongSelf && strongSelf.delegate)
        {
            [strongSelf.delegate requestDocument:strongSelf didFailWithError:err];
        }
    };

    
    RKObjectManager *thisObjectManager = (RKObjectManager *)objectManager;
    
    [thisObjectManager getObject:nil
                            path:self.path
                      parameters:nil
                         success:successBlock
                         failure:failureBlock];
}

+ (void)configureObjectManager:(id)objectManager
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
                                                                                       pathPattern:ICDREQUESTDOCUMENT_PATHPATTERN
                                                                                           keyPath:nil
                                                                                       statusCodes:statusCodes];
    
    // Configure
    [(RKObjectManager *)objectManager addResponseDescriptor:responseDescriptor];
}

@end



@implementation ICDRequestDocumentDictionary

@end
