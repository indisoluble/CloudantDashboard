//
//  ICDRequestAddRevisionTests.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 28/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "ICDRequestAddRevision.h"

#import "ICDMockRKObjectManager.h"

#import "NSDictionary+CloudantSpecialKeys.h"



@interface ICDRequestAddRevisionTestsDelegateImplementation : NSObject <ICDRequestAddRevisionDelegate>

@property (strong, nonatomic) ICDModelDocument *lastRevisionNotified;
@property (assign, nonatomic) NSUInteger lastRevisionNotifiedCounter;

@property (strong, nonatomic) NSError *lastErrorNotified;
@property (assign, nonatomic) NSUInteger lastErrorNotifiedCounter;

@end



@implementation ICDRequestAddRevisionTestsDelegateImplementation

#pragma mark - Init object
- (id)init
{
    self = [super init];
    if (self)
    {
        _lastRevisionNotified = nil;
        _lastRevisionNotifiedCounter = 0;
        
        _lastErrorNotified = nil;
        _lastErrorNotifiedCounter = 0;
    }
    
    return self;
}


#pragma mark - ICDRequestAddRevisionDelegate methods
- (void)requestAddRevision:(id<ICDRequestProtocol>)request didAddRevision:(ICDModelDocument *)revision
{
    self.lastRevisionNotified = revision;
    self.lastRevisionNotifiedCounter++;
}

- (void)requestAddRevision:(id<ICDRequestProtocol>)request didFailWithError:(NSError *)error
{
    self.lastErrorNotified = error;
    self.lastErrorNotifiedCounter++;
}

@end



@interface ICDRequestAddRevisionTestsObserver : NSObject

@property (strong, nonatomic) ICDModelDocument *lastRevisionNotified;
@property (assign, nonatomic) NSUInteger lastRevisionNotifiedCounter;

@property (strong, nonatomic) NSError *lastErrorNotified;
@property (assign, nonatomic) NSUInteger lastErrorNotifiedCounter;

- (void)didReceiveDidAddRevisionNotification:(NSNotification *)notification;
- (void)didReceiveDidFailNotification:(NSNotification *)notification;

@end



@implementation ICDRequestAddRevisionTestsObserver

#pragma mark - Public methods
- (void)didReceiveDidAddRevisionNotification:(NSNotification *)notification
{
    self.lastRevisionNotified = notification.userInfo[kICDRequestAddRevisionNotificationDidAddRevisionUserInfoKeyRevision];
    self.lastRevisionNotifiedCounter++;
}

- (void)didReceiveDidFailNotification:(NSNotification *)notification
{
    self.lastErrorNotified = notification.userInfo[kICDRequestAddRevisionNotificationDidFailUserInfoKeyError];
    self.lastErrorNotifiedCounter++;
}

@end



@interface ICDRequestAddRevisionTests : XCTestCase

@property (strong, nonatomic) ICDRequestAddRevision *addRevisionRequest;
@property (strong, nonatomic) ICDRequestAddRevisionTestsDelegateImplementation *addRevisionRequestDelegate;
@property (strong, nonatomic) ICDRequestAddRevisionTestsObserver *addRevisionRequestObserver;

@property (strong, nonatomic) ICDMockRKObjectManager *mockObjectManager;
@property (strong, nonatomic) ICDMockRKMappingResult *mockMappingResult;

@end



@implementation ICDRequestAddRevisionTests

- (void)setUp
{
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.addRevisionRequest = [[ICDRequestAddRevision alloc] initWithDatabaseName:@"dbName"
                                                                       documentId:@"docId"
                                                                      documentRev:@"docRec"
                                                                     documentData:@{}];
    
    self.addRevisionRequestDelegate = [[ICDRequestAddRevisionTestsDelegateImplementation alloc] init];
    self.addRevisionRequest.delegate = self.addRevisionRequestDelegate;
    
    self.addRevisionRequestObserver = [[ICDRequestAddRevisionTestsObserver alloc] init];
    [self.addRevisionRequest.notification addDidAddRevisionNotificationObserver:self.addRevisionRequestObserver
                                                                       selector:@selector(didReceiveDidAddRevisionNotification:)
                                                                         sender:nil];
    [self.addRevisionRequest.notification addDidFailNotificationObserver:self.addRevisionRequestObserver
                                                                selector:@selector(didReceiveDidFailNotification:)
                                                                  sender:nil];
    
    self.mockObjectManager = [[ICDMockRKObjectManager alloc] init];
    
    self.mockMappingResult = [[ICDMockRKMappingResult alloc] init];
    self.mockMappingResult.firstObjectResult = @"firstObject";
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [self.addRevisionRequest.notification removeDidAddRevisionNotificationObserver:self.addRevisionRequestObserver sender:nil];
    [self.addRevisionRequest.notification removeDidFailNotificationObserver:self.addRevisionRequestObserver sender:nil];
    self.addRevisionRequestObserver = nil;
    
    self.addRevisionRequest.delegate = nil;
    self.addRevisionRequestDelegate = nil;
    
    self.addRevisionRequest = nil;
    
    [super tearDown];
}

- (void)testSimpleInitFails
{
    XCTAssertNil([[ICDRequestAddRevision alloc] init],
                 @"A revision can not be created if we don't know the database name and document id, as well as the data to add to the revision");
}

- (void)testInitWithoutADatabaseNameFails
{
    XCTAssertNil([[ICDRequestAddRevision alloc] initWithDatabaseName:nil documentId:@"docId" documentRev:@"docRev" documentData:@{}],
                 @"The database name is required to find the document");
}

- (void)testInitWithEmptyDatabaseNameFails
{
    XCTAssertNil([[ICDRequestAddRevision alloc] initWithDatabaseName:@"" documentId:@"docId" documentRev:@"docRev" documentData:@{}],
                 @"The database name is required to find the document");
}

- (void)testInitWithoutADocumentIdFails
{
    XCTAssertNil([[ICDRequestAddRevision alloc] initWithDatabaseName:@"dbName" documentId:nil documentRev:@"docRev" documentData:@{}],
                 @"The document id is require to find the document");
}

- (void)testInitWithEmptyDocumentIdFails
{
    XCTAssertNil([[ICDRequestAddRevision alloc] initWithDatabaseName:@"dbName" documentId:@"" documentRev:@"docRev" documentData:@{}],
                 @"The document id is require to find the document");
}

- (void)testInitWithoutADocumentRevFails
{
    XCTAssertNil([[ICDRequestAddRevision alloc] initWithDatabaseName:@"dbName" documentId:@"docId" documentRev:nil documentData:@{}],
                 @"The document rev is require to find the document");
}

- (void)testInitWithEmptyDocumentRevFails
{
    XCTAssertNil([[ICDRequestAddRevision alloc] initWithDatabaseName:@"dbName" documentId:@"docId" documentRev:@"" documentData:@{}],
                 @"The document rev is require to find the document");
}

- (void)testInitWithoutDocumentDataFails
{
    XCTAssertNil([[ICDRequestAddRevision alloc] initWithDatabaseName:@"dbName" documentId:@"docId" documentRev:@"docRev" documentData:nil],
                 @"If not data is provided, there is nothing to add to the document");
}

- (void)testInitWithADocumentIdInDocumentDataFails
{
    NSDictionary *data = @{kNSDictionaryCloudantSpecialKeysDocumentId: @"docId"};
    
    XCTAssertNil([[ICDRequestAddRevision alloc] initWithDatabaseName:@"dbName" documentId:@"docId" documentRev:@"docRev" documentData:data],
                 @"The documentID is only provided as a parameter");
}

- (void)testInitWithADocumentRevInDocumemtDataFails
{
    NSDictionary *data = @{kNSDictionaryCloudantSpecialKeysDocumentRev: @"docRev"};
    
    XCTAssertNil([[ICDRequestAddRevision alloc] initWithDatabaseName:@"dbName" documentId:@"docId" documentRev:@"docRev" documentData:data],
                 @"A revision number is not required becuase we want to create a new one");
}

- (void)testExecuteRequestInformsSuccessToDelegate
{
    self.mockObjectManager.postObjectSuccessResult = self.mockMappingResult;
    
    [self.addRevisionRequest executeRequestWithObjectManager:self.mockObjectManager];
    
    XCTAssertTrue((self.addRevisionRequestDelegate.lastRevisionNotifiedCounter == 1) &&
                  [self.mockMappingResult.firstObjectResult isEqual:self.addRevisionRequestDelegate.lastRevisionNotified] &&
                  (self.addRevisionRequestDelegate.lastErrorNotifiedCounter == 0),
                  @"Success counter: %lu. Failure counter: %lu. Expected: %@. Received: %@",
                  (unsigned long)self.addRevisionRequestDelegate.lastRevisionNotifiedCounter,
                  (unsigned long)self.addRevisionRequestDelegate.lastErrorNotifiedCounter,
                  self.mockMappingResult.firstObjectResult,
                  self.addRevisionRequestDelegate.lastRevisionNotified);
}

- (void)testExecuteRequestInformsFailureToDelegate
{
    self.mockObjectManager.postObjectFailureResult = (NSError *)@"error";
    
    [self.addRevisionRequest executeRequestWithObjectManager:self.mockObjectManager];
    
    XCTAssertTrue((self.addRevisionRequestDelegate.lastErrorNotifiedCounter == 1) &&
                  [self.mockObjectManager.postObjectFailureResult isEqual:self.addRevisionRequestDelegate.lastErrorNotified] &&
                  (self.addRevisionRequestDelegate.lastRevisionNotifiedCounter == 0),
                  @"Failure counter: %lu. Success counter: %lu. Expected: %@. Received: %@",
                  (unsigned long)self.addRevisionRequestDelegate.lastErrorNotifiedCounter,
                  (unsigned long)self.addRevisionRequestDelegate.lastRevisionNotifiedCounter,
                  self.mockObjectManager.postObjectFailureResult,
                  self.addRevisionRequestDelegate.lastErrorNotified);
                  
}

- (void)testExecuteRequestInformsSuccessToObserver
{
    self.mockObjectManager.postObjectSuccessResult = self.mockMappingResult;
    
    [self.addRevisionRequest executeRequestWithObjectManager:self.mockObjectManager];
    
    XCTAssertTrue((self.addRevisionRequestObserver.lastRevisionNotifiedCounter == 1) &&
                  [self.mockMappingResult.firstObjectResult isEqual:self.addRevisionRequestObserver.lastRevisionNotified] &&
                  (self.addRevisionRequestObserver.lastErrorNotifiedCounter == 0),
                  @"Success counter: %lu. Failure counter: %lu. Expected: %@. Received: %@",
                  (unsigned long)self.addRevisionRequestObserver.lastRevisionNotifiedCounter,
                  (unsigned long)self.addRevisionRequestObserver.lastErrorNotifiedCounter,
                  self.mockMappingResult.firstObjectResult,
                  self.addRevisionRequestObserver.lastRevisionNotified);
}

- (void)testExecuteRequestInformsFailureToObserver
{
    self.mockObjectManager.postObjectFailureResult = (NSError *)@"error";
    
    [self.addRevisionRequest executeRequestWithObjectManager:self.mockObjectManager];
    
    XCTAssertTrue((self.addRevisionRequestObserver.lastErrorNotifiedCounter == 1) &&
                  [self.mockObjectManager.postObjectFailureResult isEqual:self.addRevisionRequestObserver.lastErrorNotified] &&
                  (self.addRevisionRequestObserver.lastRevisionNotifiedCounter == 0),
                  @"Failure counter: %lu. Success counter: %lu. Expected: %@. Received: %@",
                  (unsigned long)self.addRevisionRequestObserver.lastErrorNotifiedCounter,
                  (unsigned long)self.addRevisionRequestObserver.lastRevisionNotifiedCounter,
                  self.mockObjectManager.postObjectFailureResult,
                  self.addRevisionRequestObserver.lastErrorNotified);
    
}

@end
