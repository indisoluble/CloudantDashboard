//
//  ICDRequestCreateDocument.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 25/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import <RestKit/RestKit.h>

#import "ICDRequestCreateDocument.h"

#import "ICDModelDocument.h"



#define ICDREQUESTCREATEDOCUMENT_PATH_FORMAT    @"/%@"

#define ICDREQUESTCREATEDOCUMENT_STATUSCODE_CREATED 201

#define ICDREQUESTCREATEDOCUMENT_JSON_KEY_ID    @"id"
#define ICDREQUESTCREATEDOCUMENT_JSON_KEY_REV   @"rev"



@interface ICDRequestCreateDocument ()

@property (strong, nonatomic) NSString *path;
@property (strong, nonatomic) RKRequestDescriptor *requestDescriptor;
@property (strong, nonatomic) RKResponseDescriptor *responseDescriptor;

@end



@implementation ICDRequestCreateDocument

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
            _path = [NSString stringWithFormat:ICDREQUESTCREATEDOCUMENT_PATH_FORMAT, trimmedDBName];
            _requestDescriptor = [ICDRequestCreateDocument requestDescriptor];
            _responseDescriptor = [ICDRequestCreateDocument responseDescriptorForSuccessWithPath:_path];
        }
    }
    
    return self;
}


#pragma mark - ICDRequestProtocol methods
- (void)asynExecuteRequestWithObjectManager:(id)objectManager
                          completionHandler:(ICDRequestProtocolCompletionHandlerBlockType)completionHandler
{
    RKObjectManager *thisObjectManager = (RKObjectManager *)objectManager;
    RKRequestDescriptor *thisRequestDescriptor = self.requestDescriptor;
    RKResponseDescriptor *thisResponseDescriptor = self.responseDescriptor;
    
    // Add configuration
    [thisObjectManager addRequestDescriptor:thisRequestDescriptor];
    [thisObjectManager addResponseDescriptor:thisResponseDescriptor];
    
    // Execute request
    __weak ICDRequestCreateDocument *weakSelf = self;
    
    void (^successBlock)(RKObjectRequestOperation *op, RKMappingResult *mapResult) = ^(RKObjectRequestOperation *op, RKMappingResult *mapResult)
    {
        // Remove configuration
        [thisObjectManager removeRequestDescriptor:thisRequestDescriptor];
        [thisObjectManager removeResponseDescriptor:thisResponseDescriptor];
        
        // Notify
        __strong ICDRequestCreateDocument *strongSelf = weakSelf;
        if (strongSelf && strongSelf.delegate)
        {
            [strongSelf.delegate requestCreateDocument:strongSelf didCreateDocument:[mapResult firstObject]];
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
        [thisObjectManager removeRequestDescriptor:thisRequestDescriptor];
        [thisObjectManager removeResponseDescriptor:thisResponseDescriptor];
        
        // Notify
        __strong ICDRequestCreateDocument *strongSelf = weakSelf;
        if (strongSelf && strongSelf.delegate)
        {
            [strongSelf.delegate requestCreateDocument:strongSelf didFailWithError:err];
        }
        
        // Finish execution
        if (completionHandler)
        {
            completionHandler();
        }
    };
    
    ICDModelDocument *emptyDocument = [[ICDModelDocument alloc] init];
    [thisObjectManager postObject:emptyDocument path:self.path parameters:nil success:successBlock failure:failureBlock];
}


#pragma mark - Private class methods
+ (RKRequestDescriptor *)requestDescriptor
{
    // Mapping
    RKObjectMapping *mapping = [RKObjectMapping requestMapping];
    
    // Request descriptor
    RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:mapping
                                                                                   objectClass:[ICDModelDocument class]
                                                                                   rootKeyPath:nil
                                                                                        method:RKRequestMethodPOST];
    
    return requestDescriptor;
}

+ (RKResponseDescriptor *)responseDescriptorForSuccessWithPath:(NSString *)path
{
    // Mapping
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[ICDModelDocument class]];
    [mapping addAttributeMappingsFromDictionary:@{ICDREQUESTCREATEDOCUMENT_JSON_KEY_ID: ICDMODELDOCUMENT_PROPERTY_KEY_ID,
                                                  ICDREQUESTCREATEDOCUMENT_JSON_KEY_REV: ICDMODELDOCUMENT_PROPERTY_KEY_REV}];
    
    // Status code
    NSIndexSet *statusCodes = [NSIndexSet indexSetWithIndex:ICDREQUESTCREATEDOCUMENT_STATUSCODE_CREATED];
    
    // Response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:path
                                                                                           keyPath:nil
                                                                                       statusCodes:statusCodes];
    
    return responseDescriptor;
}

@end
