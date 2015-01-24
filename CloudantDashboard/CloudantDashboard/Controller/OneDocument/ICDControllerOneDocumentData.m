//
//  ICDControllerOneDocumentData.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 07/01/2015.
//  Copyright (c) 2015 Enrique de la Torre. All rights reserved.
//

#import "ICDControllerOneDocumentData.h"

#import "ICDNetworkManagerFactory.h"

#import "ICDRequestDocument.h"
#import "ICDRequestCustomAddRevision.h"

#import "ICDLog.h"

#import "NSDictionary+CloudantSpecialKeys.h"



@interface ICDControllerOneDocumentData () <ICDRequestDocumentDelegate, ICDRequestAddRevisionDelegate>

@property (strong, nonatomic, readonly) id<ICDNetworkManagerProtocol> networkManager;

@property (strong, nonatomic, readonly) NSString *databaseNameOrNil;

@property (strong, nonatomic) NSString *documentIdOrNil;
@property (strong, nonatomic) NSString *documentRevOrNil;
@property (strong, nonatomic) NSDictionary *fullDocument;

@property (assign, nonatomic) BOOL requestDocumentOngoing;
@property (assign, nonatomic) BOOL requestAddRevisionOngoing;

@end



@implementation ICDControllerOneDocumentData

#pragma mark - Init object
- (id)init
{
    return [self initWithNetworkManager:nil databaseName:nil documentId:nil];
}

- (id)initWithNetworkManager:(id<ICDNetworkManagerProtocol>)networkManagerOrNil
                databaseName:(NSString *)databaseNameOrNil
                  documentId:(NSString *)documentIdOrNil
{
    self = [super init];
    if (self)
    {
        _networkManager = (networkManagerOrNil ? networkManagerOrNil : [ICDNetworkManagerFactory networkManager]);
        
        _databaseNameOrNil = databaseNameOrNil;
        _documentIdOrNil = documentIdOrNil;
        _documentRevOrNil = nil;
        
        _fullDocument = @{};
        
        _requestDocumentOngoing = NO;
        _requestAddRevisionOngoing = NO;
    }
    
    return self;
}


#pragma mark - ICDRequestDocumentDelegate methods
- (void)requestDocument:(id<ICDRequestProtocol>)request didGetDocument:(NSDictionary *)document
{
    self.requestDocumentOngoing = NO;
    
    self.documentRevOrNil = (NSString *)[document objectForKey:kNSDictionaryCloudantSpecialKeysDocumentRev];
    self.fullDocument = document;
    
    if (self.delegate)
    {
        [self.delegate icdControllerOneDocumentData:self didGetFullDocWithResult:YES];
    }
}

- (void)requestDocument:(id<ICDRequestProtocol>)request didFailWithError:(NSError *)error
{
    ICDLogError(@"Error: %@", error);
    
    self.requestDocumentOngoing = NO;
    
    if (self.delegate)
    {
        [self.delegate icdControllerOneDocumentData:self didGetFullDocWithResult:NO];
    }
}


#pragma mark - ICDRequestAddRevisionDelegate methods
- (void)requestAddRevision:(id<ICDRequestProtocol>)request didAddRevision:(ICDModelDocument *)revision
{
    self.requestAddRevisionOngoing = NO;
    
    self.documentIdOrNil = revision.documentId;
    self.documentRevOrNil = revision.documentRev;
    self.fullDocument = [(ICDRequestCustomAddRevision *)request docData];
    
    if (self.delegate)
    {
        [self.delegate icdControllerOneDocumentData:self didUpdateDocWithResult:YES];
    }
}

- (void)requestAddRevision:(id<ICDRequestProtocol>)request didFailWithError:(NSError *)error
{
    ICDLogError(@"Error: %@", error);
    
    self.requestAddRevisionOngoing = NO;
    
    if (self.delegate)
    {
        [self.delegate icdControllerOneDocumentData:self didUpdateDocWithResult:NO];
    }
}


#pragma mark - Public methods
- (BOOL)asyncGetFullDocument
{
    return [self executeRequestDocument];
}

- (BOOL)asyncUpdateDocumentWithData:(NSDictionary *)data
{
    return [self executeRequestAddRevisionWithData:data];
}


#pragma mark - Private methods
- (BOOL)executeRequestDocument
{
    // Check
    if (self.requestDocumentOngoing)
    {
        ICDLogTrace(@"Already executing this request");
        
        return NO;
    }
    
    // Create
    ICDRequestDocument *requestDocument = [[ICDRequestDocument alloc] initWithDatabaseName:self.databaseNameOrNil
                                                                                documentId:self.documentIdOrNil];
    if (!requestDocument)
    {
        ICDLogWarning(@"Request not created with dbName <%@> and docId <%@>", self.databaseNameOrNil, self.documentIdOrNil);
        
        return NO;
    }
    
    requestDocument.delegate = self;
    
    // Execute
    self.requestDocumentOngoing = [self.networkManager asyncExecuteRequest:requestDocument];
    
    return self.requestDocumentOngoing;
}

- (BOOL)executeRequestAddRevisionWithData:(NSDictionary *)data
{
    // Check
    if (self.requestAddRevisionOngoing)
    {
        ICDLogTrace(@"Already executing this request");
        
        return NO;
    }
    
    // Create
    ICDRequestCustomAddRevision *requestAddRev = [[ICDRequestCustomAddRevision alloc] initWithDatabaseName:self.databaseNameOrNil
                                                                                                documentId:self.documentIdOrNil
                                                                                               documentRev:self.documentRevOrNil
                                                                                              documentData:data];
    if (!requestAddRev)
    {
        ICDLogWarning(@"Request not created with dbName <%@>, document <%@, %@> and data <%@>",
                      self.databaseNameOrNil, self.documentIdOrNil, self.documentRevOrNil, data);
        
        return NO;
    }
    
    requestAddRev.delegate = self;
    
    // Execute
    self.requestAddRevisionOngoing = [self.networkManager asyncExecuteRequest:requestAddRev];
    
    return self.requestAddRevisionOngoing;
}

@end
