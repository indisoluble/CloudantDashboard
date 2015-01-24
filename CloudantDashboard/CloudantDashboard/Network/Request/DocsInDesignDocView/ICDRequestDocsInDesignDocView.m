//
//  ICDRequestDocsInDesignDocView.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 23/01/2015.
//  Copyright (c) 2015 Enrique de la Torre. All rights reserved.
//

#import <RestKit/RestKit.h>

#import "ICDRequestDocsInDesignDocView.h"

#import "ICDModelDocument.h"

#import "ICDLog.h"

#import "NSString+CloudantDesignDocId.h"



#define ICDREQUESTDOCSINDESIGNDOCVIEW_JSON_DOCUMENT_KEY_ID  @"id"

#define ICDREQUESTDOCSINDESIGNDOCVIEW_PATH_FORMAT   @"/%@/%@/_view/%@"
#define ICDREQUESTDOCSINDESIGNDOCVIEW_KEYPATH       @"rows"



@interface ICDRequestDocsInDesignDocView ()

@property (strong, nonatomic) NSString *viewname;

@property (strong, nonatomic) NSString *path;

@end



@implementation ICDRequestDocsInDesignDocView

#pragma mark - Init object
- (id)init
{
    return [self initWithDatabaseName:nil designDocId:nil viewname:nil];
}

- (id)initWithDatabaseName:(NSString *)dbName
               designDocId:(NSString *)designDocId
                  viewname:(NSString *)viewname
{
    self = [super init];
    if (self)
    {
        NSCharacterSet *whiteSpacesAndNewLines = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        
        NSString *trimmedDBName = (dbName ?
                                   [dbName stringByTrimmingCharactersInSet:whiteSpacesAndNewLines] :
                                   nil);
        NSString *trimmedDesignDocId = (designDocId ?
                                        [designDocId stringByTrimmingCharactersInSet:whiteSpacesAndNewLines] :
                                        nil);
        NSString *trimmedViewname = (viewname ?
                                     [viewname stringByTrimmingCharactersInSet:whiteSpacesAndNewLines] :
                                     nil);
        
        if (!trimmedDBName ||
            !trimmedDesignDocId ||
            !trimmedViewname ||
            ([trimmedDBName length] == 0) ||
            ([trimmedViewname length] == 0)||
            ![trimmedDesignDocId isDesignDocId])
        {
            self = nil;
        }
        else
        {
             _viewname = trimmedViewname;
            
            _path = [NSString stringWithFormat:ICDREQUESTDOCSINDESIGNDOCVIEW_PATH_FORMAT,
                     trimmedDBName, trimmedDesignDocId, _viewname];
        }
    }
    
    return self;
}


#pragma mark - ICDRequestProtocol methods
- (void)asynExecuteRequestWithObjectManager:(id)objectManager
                          completionHandler:(ICDRequestProtocolCompletionHandlerBlockType)completionHandler
{
    RKObjectManager *thisObjectManager = (RKObjectManager *)objectManager;
    RKResponseDescriptor *thisResponseDescriptor = [ICDRequestDocsInDesignDocView responseDescriptorForPath:self.path];
    
    NSString *thisViewname = self.viewname;
    
    // Add configuration
    [thisObjectManager addResponseDescriptor:thisResponseDescriptor];
    
    // Execute request
    __weak ICDRequestDocsInDesignDocView *weakSelf = self;
    
    void (^successBlock)(RKObjectRequestOperation *op, RKMappingResult *mapResult) = ^(RKObjectRequestOperation *op, RKMappingResult *mapResult)
    {
        // Remove configuration
        [thisObjectManager removeResponseDescriptor:thisResponseDescriptor];
        
        // Notify
        ICDLogTrace(@"Found %lu documents in %@", (unsigned long)[mapResult.array count], thisViewname);
        
        __strong ICDRequestDocsInDesignDocView *strongSelf = weakSelf;
        if (strongSelf && strongSelf.delegate)
        {
            [strongSelf.delegate requestDocsInDesignDocView:strongSelf didGetDocuments:mapResult.array];
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
        __strong ICDRequestDocsInDesignDocView *strongSelf = weakSelf;
        if (strongSelf && strongSelf.delegate)
        {
            [strongSelf.delegate requestDocsInDesignDocView:strongSelf didFailWithError:err];
        }
        
        // Finish execution
        if (completionHandler)
        {
            completionHandler();
        }
    };
    
    [thisObjectManager getObjectsAtPath:self.path parameters:nil success:successBlock failure:failureBlock];
}


#pragma mark - Private class methods
+ (RKResponseDescriptor *)responseDescriptorForPath:(NSString *)path
{
    // Mapping
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[ICDModelDocument class]];
    [mapping addAttributeMappingsFromDictionary:@{ICDREQUESTDOCSINDESIGNDOCVIEW_JSON_DOCUMENT_KEY_ID: ICDMODELDOCUMENT_PROPERTY_KEY_ID}];
    
    // Status code
    NSIndexSet *statusCodes = [NSIndexSet indexSetWithIndex:RKStatusCodeClassSuccessful];
    
    // Response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping
                                                                                            method:RKRequestMethodGET
                                                                                       pathPattern:path
                                                                                           keyPath:ICDREQUESTDOCSINDESIGNDOCVIEW_KEYPATH
                                                                                       statusCodes:statusCodes];
    
    return responseDescriptor;
}

@end
