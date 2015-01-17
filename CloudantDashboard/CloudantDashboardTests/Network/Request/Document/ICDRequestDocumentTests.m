//
//  ICDRequestDocumentTests.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 23/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "ICDRequestDocument.h"

#import "ICDMockRKObjectManager.h"



#define ICDREQUESTDOCUMENTTESTS_DBNAME  @"databaseName"
#define ICDREQUESTDOCUMENTTESTS_DOCID   @"documentId"



@interface ICDRequestDocumentTests : XCTestCase

@property (strong, nonatomic) ICDRequestDocument *documentRequest;

@property (strong, nonatomic) ICDMockRKObjectManager *mockObjectManager;
@property (strong, nonatomic) ICDMockRKMappingResult *mockMappingResult;

@end



@implementation ICDRequestDocumentTests

- (void)setUp
{
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.documentRequest = [[ICDRequestDocument alloc] initWithDatabaseName:ICDREQUESTDOCUMENTTESTS_DBNAME
                                                                 documentId:ICDREQUESTDOCUMENTTESTS_DOCID];
    
    self.mockObjectManager = [[ICDMockRKObjectManager alloc] init];
    
    self.mockMappingResult = [[ICDMockRKMappingResult alloc] init];
    self.mockMappingResult.firstObjectResult = @"firstObject";
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    self.mockMappingResult = nil;
    self.mockObjectManager = nil;
    
    self.documentRequest = nil;
    
    [super tearDown];
}

- (void)testSimpleInitFails
{
    XCTAssertNil([[ICDRequestDocument alloc] init],
                 @"Database and document id are required to find a document");
}

- (void)testInitWithoutADatabaseNameFails
{
    XCTAssertNil([[ICDRequestDocument alloc] initWithDatabaseName:nil documentId:ICDREQUESTDOCUMENTTESTS_DOCID],
                 @"Database and document id are required to find a document");
}

- (void)testInitWithoutADocumentIdFails
{
    XCTAssertNil([[ICDRequestDocument alloc] initWithDatabaseName:ICDREQUESTDOCUMENTTESTS_DBNAME documentId:nil],
                 @"Database and document id are required to find a document");
}

- (void)testInitWithEmptyDatabaseNameFails
{
    XCTAssertNil([[ICDRequestDocument alloc] initWithDatabaseName:@"" documentId:ICDREQUESTDOCUMENTTESTS_DOCID],
                 @"An empty name is not a valid database name");
}

- (void)testInitWithDatabaseNameEqualToSpacesFails
{
    XCTAssertNil([[ICDRequestDocument alloc] initWithDatabaseName:@"  " documentId:ICDREQUESTDOCUMENTTESTS_DOCID],
                 @"Only spaces is equal to an empty database name");
}

- (void)testInitWithEmptyDocumentIdFails
{
    XCTAssertNil([[ICDRequestDocument alloc] initWithDatabaseName:ICDREQUESTDOCUMENTTESTS_DBNAME documentId:@""],
                 @"An empty id is not a valid id for a document");
}

- (void)testInitWithDocumentIdEqualToSpacesFails
{
    XCTAssertNil([[ICDRequestDocument alloc] initWithDatabaseName:ICDREQUESTDOCUMENTTESTS_DBNAME documentId:@"  "],
                 @"Only spaces is equal to an empty document id");
}

- (void)testExecuteRequestCallCompletionHandlerIfItSucceeds
{
    self.mockObjectManager.successResult = self.mockMappingResult;
    
    __block BOOL wasCompletionHandlerExecuted = NO;
    [self.documentRequest asynExecuteRequestWithObjectManager:self.mockObjectManager completionHandler:^{
        wasCompletionHandlerExecuted = YES;
    }];
    
    XCTAssertTrue(wasCompletionHandlerExecuted, @"CompletionHandler must be executed by the request always");
}

- (void)testExecuteRequestCallCompletionHandlerIfItFails
{
    self.mockObjectManager.failureResult = (NSError *)@"error";
    
    __block BOOL wasCompletionHandlerExecuted = NO;
    [self.documentRequest asynExecuteRequestWithObjectManager:self.mockObjectManager completionHandler:^{
        wasCompletionHandlerExecuted = YES;
    }];
    
    XCTAssertTrue(wasCompletionHandlerExecuted, @"CompletionHandler must be executed by the request always");
}

@end
