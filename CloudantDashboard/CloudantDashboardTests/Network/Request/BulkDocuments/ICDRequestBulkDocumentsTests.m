//
//  ICDRequestBulkDocumentsTests.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 06/01/2015.
//  Copyright (c) 2015 Enrique de la Torre. All rights reserved.
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

#import "ICDRequestBulkDocuments.h"

#import "ICDMockRKObjectManager.h"

#import "NSDictionary+CloudantSpecialKeys.h"



#define ICDREQUESTBULKDOCUMENTSTESTS_DBNAME         @"dbName"
#define ICDREQUESTBULKDOCUMENTSTESTS_DOCID          @"docId"
#define ICDREQUESTBULKDOCUMENTSTESTS_DOCREV         @"docRec"
#define ICDREQUESTBULKDOCUMENTSTESTS_NUMBEROFCOPIES 10



@interface ICDRequestBulkDocumentsTests : XCTestCase

@property (strong, nonatomic) ICDRequestBulkDocuments *bulkDocumentsRequest;

@property (strong, nonatomic) ICDMockRKObjectManager *mockObjectManager;
@property (strong, nonatomic) ICDMockRKMappingResult *mockMappingResult;

@end



@implementation ICDRequestBulkDocumentsTests

- (void)setUp
{
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.bulkDocumentsRequest = [[ICDRequestBulkDocuments alloc] initWithDatabaseName:ICDREQUESTBULKDOCUMENTSTESTS_DBNAME
                                                                         documentData:@{}
                                                                       numberOfCopies:ICDREQUESTBULKDOCUMENTSTESTS_NUMBEROFCOPIES];
    
    self.mockObjectManager = [[ICDMockRKObjectManager alloc] init];
    
    self.mockMappingResult = [[ICDMockRKMappingResult alloc] init];
    self.mockMappingResult.arrayResult = @[];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    self.mockMappingResult = nil;
    self.mockObjectManager = nil;
    
    self.bulkDocumentsRequest = nil;
    
    [super tearDown];
}

- (void)testSimpleInitFails
{
    XCTAssertNil([[ICDRequestBulkDocuments alloc] init],
                 @"we need a database name to know where to create the documents");
}

- (void)testInitWithoutADatabaseNameFails
{
    XCTAssertNil([[ICDRequestBulkDocuments alloc] initWithDatabaseName:nil
                                                          documentData:@{}
                                                        numberOfCopies:ICDREQUESTBULKDOCUMENTSTESTS_NUMBEROFCOPIES],
                 @"we need a database name to know where to create the documents");
}

- (void)testInitWithEmptyDatabaseNameFails
{
    XCTAssertNil([[ICDRequestBulkDocuments alloc] initWithDatabaseName:@""
                                                          documentData:@{}
                                                        numberOfCopies:ICDREQUESTBULKDOCUMENTSTESTS_NUMBEROFCOPIES],
                 @"An empty name is not a valid database name");
}

- (void)testInitWithDatabaseNameEqualToSpacesFails
{
    XCTAssertNil([[ICDRequestBulkDocuments alloc] initWithDatabaseName:@"  "
                                                          documentData:@{}
                                                        numberOfCopies:ICDREQUESTBULKDOCUMENTSTESTS_NUMBEROFCOPIES],
                 @"Only spaces is equal to an empty database name");
}

- (void)testInitWithoutDocumentDataFails
{
    XCTAssertNil([[ICDRequestBulkDocuments alloc] initWithDatabaseName:ICDREQUESTBULKDOCUMENTSTESTS_DBNAME
                                                          documentData:nil
                                                        numberOfCopies:ICDREQUESTBULKDOCUMENTSTESTS_NUMBEROFCOPIES],
                 @"The new documemts have to be created with some data");
}

- (void)testInitWithADocumentIdInDocumentDataFails
{
    NSDictionary *data = @{kNSDictionaryCloudantSpecialKeysDocumentId: ICDREQUESTBULKDOCUMENTSTESTS_DOCID};
    
    XCTAssertNil([[ICDRequestBulkDocuments alloc] initWithDatabaseName:ICDREQUESTBULKDOCUMENTSTESTS_DBNAME
                                                          documentData:data
                                                        numberOfCopies:ICDREQUESTBULKDOCUMENTSTESTS_NUMBEROFCOPIES],
                 @"The document ID will be set by the server");
}

- (void)testInitWithADocumentRevInDocumemtDataFails
{
    NSDictionary *data = @{kNSDictionaryCloudantSpecialKeysDocumentRev: ICDREQUESTBULKDOCUMENTSTESTS_DOCID};
    
    XCTAssertNil([[ICDRequestBulkDocuments alloc] initWithDatabaseName:ICDREQUESTBULKDOCUMENTSTESTS_DBNAME
                                                          documentData:data
                                                        numberOfCopies:ICDREQUESTBULKDOCUMENTSTESTS_NUMBEROFCOPIES],
                 @"The document revision will be set by the server");
}

- (void)testInitWithNumberOfCopiesEqualTo0Fails
{
    XCTAssertNil([[ICDRequestBulkDocuments alloc] initWithDatabaseName:ICDREQUESTBULKDOCUMENTSTESTS_DBNAME
                                                          documentData:@{}
                                                        numberOfCopies:0],
                 @"At least you have to create one document");
}

- (void)testExecuteRequestCallCompletionHandlerIfItSucceeds
{
    self.mockObjectManager.successResult = self.mockMappingResult;
    
    __block BOOL wasCompletionHandlerExecuted = NO;
    [self.bulkDocumentsRequest asynExecuteRequestWithObjectManager:self.mockObjectManager completionHandler:^{
        wasCompletionHandlerExecuted = YES;
    }];
    
    XCTAssertTrue(wasCompletionHandlerExecuted, @"CompletionHandler must be executed by the request always");
}

- (void)testExecuteRequestCallCompletionHandlerIfItFails
{
    self.mockObjectManager.failureResult = (NSError *)@"error";
    
    __block BOOL wasCompletionHandlerExecuted = NO;
    [self.bulkDocumentsRequest asynExecuteRequestWithObjectManager:self.mockObjectManager completionHandler:^{
        wasCompletionHandlerExecuted = YES;
    }];
    
    XCTAssertTrue(wasCompletionHandlerExecuted, @"CompletionHandler must be executed by the request always");
}

@end
