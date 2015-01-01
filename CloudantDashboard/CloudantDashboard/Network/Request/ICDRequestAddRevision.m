//
//  ICDRequestAddRevision.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 28/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import <RestKit/RestKit.h>

#import "ICDRequestAddRevision.h"

#import "ICDModelDocument.h"

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
@property (strong, nonatomic) RKResponseDescriptor *responseDescriptor;

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
            
            _responseDescriptor = [ICDRequestAddRevision responseDescriptorForSuccessWithPath:_path];
            
            _notification = (notificationOrNil ? notificationOrNil : [ICDRequestAddRevisionNotification sharedInstance]);
        }
    }
    
    return self;
}


#pragma mark - ICDRequestProtocol methods
- (void)executeRequestWithObjectManager:(id)objectManager
{
    RKObjectManager *thisObjectManager = (RKObjectManager *)objectManager;
    RKResponseDescriptor *thisResponseDescriptor = self.responseDescriptor;
    
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
        
        __strong ICDRequestAddRevision *strongSelf = weakSelf;
        if (strongSelf && strongSelf.delegate)
        {
            [strongSelf.delegate requestAddRevision:strongSelf didAddRevision:revision];
        }
        
        [thisNotification postDidAddRevisionNotificationWithDatabaseName:thisDBName revision:revision];
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
