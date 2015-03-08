//
//  ICDRequestDeleteDocumentTests.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 26/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file
//  except in compliance with the License. You may obtain a copy of the License at
//    http://www.apache.org/licenses/LICENSE-2.0
//  Unless required by applicable law or agreed to in writing, software distributed under the
//  License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
//  either express or implied. See the License for the specific language governing permissions
//  and limitations under the License.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "ICDRequestDeleteDocument.h"

#import "ICDMockRKObjectManager.h"



#define ICDREQUESTDELETEDOCUMENTTESTS_DBNAME    @"databaseName"
#define ICDREQUESTDELETEDOCUMENTTESTS_DOCID     @"documentId"
#define ICDREQUESTDELETEDOCUMENTTESTS_DOCREV    @"documentRev"



@interface ICDRequestDeleteDocumentTests : XCTestCase

@property (strong, nonatomic) ICDRequestDeleteDocument *deleteDocumentRequest;

@property (strong, nonatomic) ICDMockRKObjectManager *mockObjectManager;
@property (strong, nonatomic) ICDMockRKMappingResult *mockMappingResult;

@end



@implementation ICDRequestDeleteDocumentTests

- (void)setUp
{
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.deleteDocumentRequest = [[ICDRequestDeleteDocument alloc] initWithDatabaseName:ICDREQUESTDELETEDOCUMENTTESTS_DBNAME
                                                                             documentId:ICDREQUESTDELETEDOCUMENTTESTS_DOCID
                                                                            documentRev:ICDREQUESTDELETEDOCUMENTTESTS_DOCREV];
    
    self.mockObjectManager = [[ICDMockRKObjectManager alloc] init];
    
    self.mockMappingResult = [[ICDMockRKMappingResult alloc] init];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    self.mockMappingResult = nil;
    self.mockObjectManager = nil;
    
    self.deleteDocumentRequest = nil;
    
    [super tearDown];
}

- (void)testSimpleInitFails
{
    XCTAssertNil([[ICDRequestDeleteDocument alloc] init],
                 @"Document and database of the document are required to delete a document");
}

- (void)testInitWithoutADatabaseNameFails
{
    XCTAssertNil([[ICDRequestDeleteDocument alloc] initWithDatabaseName:nil
                                                             documentId:ICDREQUESTDELETEDOCUMENTTESTS_DOCID
                                                            documentRev:ICDREQUESTDELETEDOCUMENTTESTS_DOCREV],
                 @"Witbout a database, we do not know where to look for the document");
}

- (void)testInitWithoutADocumentIdFails
{
    XCTAssertNil([[ICDRequestDeleteDocument alloc] initWithDatabaseName:ICDREQUESTDELETEDOCUMENTTESTS_DBNAME
                                                             documentId:nil
                                                            documentRev:ICDREQUESTDELETEDOCUMENTTESTS_DOCREV],
                 @"A document can not be found without an id");
}

- (void)testInitWithoutADocumentRevFails
{
    XCTAssertNil([[ICDRequestDeleteDocument alloc] initWithDatabaseName:ICDREQUESTDELETEDOCUMENTTESTS_DBNAME
                                                             documentId:ICDREQUESTDELETEDOCUMENTTESTS_DOCID
                                                            documentRev:nil],
                 @"A document can not be found without an id");
}

- (void)testInitWithEmptyDatabaseNameFails
{
    XCTAssertNil([[ICDRequestDeleteDocument alloc] initWithDatabaseName:@""
                                                             documentId:ICDREQUESTDELETEDOCUMENTTESTS_DOCID
                                                            documentRev:ICDREQUESTDELETEDOCUMENTTESTS_DOCREV],
                 @"Witbout a database, we do not know where to look for the document");
}

- (void)testInitWithEmptyDocumentIdFails
{
    XCTAssertNil([[ICDRequestDeleteDocument alloc] initWithDatabaseName:ICDREQUESTDELETEDOCUMENTTESTS_DBNAME
                                                             documentId:@""
                                                            documentRev:ICDREQUESTDELETEDOCUMENTTESTS_DOCREV],
                 @"A document can not be found without an id");
}

- (void)testInitWithEmptyDocumentRevFails
{
    XCTAssertNil([[ICDRequestDeleteDocument alloc] initWithDatabaseName:ICDREQUESTDELETEDOCUMENTTESTS_DBNAME
                                                             documentId:ICDREQUESTDELETEDOCUMENTTESTS_DOCID
                                                            documentRev:@""],
                 @"A document can not be found without an id");
}

- (void)testInitWithDatabaseNameEqualToSpacesFails
{
    XCTAssertNil([[ICDRequestDeleteDocument alloc] initWithDatabaseName:@"  "
                                                             documentId:ICDREQUESTDELETEDOCUMENTTESTS_DOCID
                                                            documentRev:ICDREQUESTDELETEDOCUMENTTESTS_DOCREV],
                 @"Witbout a database, we do not know where to look for the document");
}

- (void)testInitWithDocumentIdToSpacesFails
{
    XCTAssertNil([[ICDRequestDeleteDocument alloc] initWithDatabaseName:ICDREQUESTDELETEDOCUMENTTESTS_DBNAME
                                                             documentId:@"  "
                                                            documentRev:ICDREQUESTDELETEDOCUMENTTESTS_DOCREV],
                 @"A document can not be found without an id");
}

- (void)testInitWithDocumentRevToSpacesFails
{
    XCTAssertNil([[ICDRequestDeleteDocument alloc] initWithDatabaseName:ICDREQUESTDELETEDOCUMENTTESTS_DBNAME
                                                             documentId:ICDREQUESTDELETEDOCUMENTTESTS_DOCID
                                                            documentRev:@"  "],
                 @"A document can not be found without an id");
}

- (void)testExecuteRequestCallCompletionHandlerIfItSucceeds
{
    self.mockObjectManager.successResult = self.mockMappingResult;
    
    __block BOOL wasCompletionHandlerExecuted = NO;
    [self.deleteDocumentRequest asynExecuteRequestWithObjectManager:self.mockObjectManager completionHandler:^{
        wasCompletionHandlerExecuted = YES;
    }];
    
    XCTAssertTrue(wasCompletionHandlerExecuted, @"CompletionHandler must be executed by the request always");
}

- (void)testExecuteRequestCallCompletionHandlerIfItFails
{
    self.mockObjectManager.failureResult = (NSError *)@"error";
    
    __block BOOL wasCompletionHandlerExecuted = NO;
    [self.deleteDocumentRequest asynExecuteRequestWithObjectManager:self.mockObjectManager completionHandler:^{
        wasCompletionHandlerExecuted = YES;
    }];
    
    XCTAssertTrue(wasCompletionHandlerExecuted, @"CompletionHandler must be executed by the request always");
}

@end
