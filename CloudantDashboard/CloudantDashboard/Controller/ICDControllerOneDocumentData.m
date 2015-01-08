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



@interface ICDControllerOneDocumentData () <ICDRequestDocumentDelegate, ICDRequestAddRevisionDelegate>

@property (strong, nonatomic, readonly) id<ICDNetworkManagerProtocol> networkManager;

@property (strong, nonatomic, readonly) NSString *databaseNameOrNil;

@property (strong, nonatomic) ICDModelDocument *documentOrNil;
@property (strong, nonatomic) NSDictionary *fullDocument;

@property (assign, nonatomic) BOOL requestDocumentOngoing;
@property (assign, nonatomic) BOOL requestAddRevisionOngoing;

@end



@implementation ICDControllerOneDocumentData

#pragma mark - Init object
- (id)init
{
    return [self initWithNetworkManager:nil databaseName:nil document:nil];
}

- (id)initWithNetworkManager:(id<ICDNetworkManagerProtocol>)networkManagerOrNil
                databaseName:(NSString *)databaseNameOrNil
                    document:(ICDModelDocument *)documentOrNil
{
    self = [super init];
    if (self)
    {
        _networkManager = (networkManagerOrNil ? networkManagerOrNil : [ICDNetworkManagerFactory networkManager]);
        
        _databaseNameOrNil = databaseNameOrNil;
        _documentOrNil = documentOrNil;
        
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
    
    self.documentOrNil = revision;
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
    NSString *documentIdOrNil = (self.documentOrNil ? self.documentOrNil.documentId : nil);
    ICDRequestDocument *requestDocument = [[ICDRequestDocument alloc] initWithDatabaseName:self.databaseNameOrNil
                                                                                documentId:documentIdOrNil];
    if (!requestDocument)
    {
        ICDLogWarning(@"Request not created with dbName <%@> and docId <%@>", self.databaseNameOrNil, documentIdOrNil);
        
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
    NSString *documentIdOrNil = (self.documentOrNil ? self.documentOrNil.documentId : nil );
    NSString *documentRevOrNil = (self.documentOrNil ? self.documentOrNil.documentRev : nil);
    ICDRequestCustomAddRevision *requestAddRev = [[ICDRequestCustomAddRevision alloc] initWithDatabaseName:self.databaseNameOrNil
                                                                                                documentId:documentIdOrNil
                                                                                               documentRev:documentRevOrNil
                                                                                              documentData:data];
    if (!requestAddRev)
    {
        ICDLogWarning(@"Request not created with dbName <%@>, document %@ and data <%@>",
                      self.databaseNameOrNil, self.documentOrNil, data);
        
        return NO;
    }
    
    requestAddRev.delegate = self;
    
    // Execute
    self.requestAddRevisionOngoing = [self.networkManager asyncExecuteRequest:requestAddRev];
    
    return self.requestAddRevisionOngoing;
}

@end
