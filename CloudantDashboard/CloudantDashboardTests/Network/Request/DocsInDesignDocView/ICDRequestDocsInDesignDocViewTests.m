//
//  ICDRequestDocsInDesignDocViewTests.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 24/01/2015.
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

#import "ICDRequestDocsInDesignDocView.h"

#import "ICDMockRKObjectManager.h"

#import "NSString+CloudantDesignDocId.h"



#define ICDREQUESTDOCSINDESIGNDOCVIEWTESTS_DBNAME       @"databaseName"
#define ICDREQUESTDOCSINDESIGNDOCVIEWTESTS_DESIGNDOCID  [NSString designDocIdWithId:@"designDocId"]
#define ICDREQUESTDOCSINDESIGNDOCVIEWTESTS_VIEWNAME     @"viewname"



@interface ICDRequestDocsInDesignDocViewTests : XCTestCase

@property (strong, nonatomic) ICDRequestDocsInDesignDocView *docsInDesignDocViewRequest;

@property (strong, nonatomic) ICDMockRKObjectManager *mockObjectManager;
@property (strong, nonatomic) ICDMockRKMappingResult *mockMappingResult;

@end



@implementation ICDRequestDocsInDesignDocViewTests

- (void)setUp
{
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.docsInDesignDocViewRequest = [[ICDRequestDocsInDesignDocView alloc] initWithDatabaseName:ICDREQUESTDOCSINDESIGNDOCVIEWTESTS_DBNAME
                                                                                      designDocId:ICDREQUESTDOCSINDESIGNDOCVIEWTESTS_DESIGNDOCID
                                                                                         viewname:ICDREQUESTDOCSINDESIGNDOCVIEWTESTS_VIEWNAME];
    
    self.mockObjectManager = [[ICDMockRKObjectManager alloc] init];
    
    self.mockMappingResult = [[ICDMockRKMappingResult alloc] init];
    self.mockMappingResult.arrayResult = @[];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    self.mockMappingResult = nil;
    self.mockObjectManager = nil;
    
    self.docsInDesignDocViewRequest = nil;
    
    [super tearDown];
}

- (void)testSimpleInitFails
{
    XCTAssertNil([[ICDRequestDocsInDesignDocView alloc] init],
                 @"Database, design doc id and viewname are required to find a design document");
}

- (void)testInitWithoutADatabaseNameFails
{
    XCTAssertNil([[ICDRequestDocsInDesignDocView alloc] initWithDatabaseName:nil
                                                                 designDocId:ICDREQUESTDOCSINDESIGNDOCVIEWTESTS_DESIGNDOCID
                                                                    viewname:ICDREQUESTDOCSINDESIGNDOCVIEWTESTS_VIEWNAME],
                 @"Database, design doc id and viewname are required to find a design document");
}

- (void)testInitWithEmptyDatabaseNameFails
{
    XCTAssertNil([[ICDRequestDocsInDesignDocView alloc] initWithDatabaseName:@""
                                                                 designDocId:ICDREQUESTDOCSINDESIGNDOCVIEWTESTS_DESIGNDOCID
                                                                    viewname:ICDREQUESTDOCSINDESIGNDOCVIEWTESTS_VIEWNAME],
                 @"An empty name is not a valid database name");
}

- (void)testInitWithDatabaseNameEqualToSpacesFails
{
    XCTAssertNil([[ICDRequestDocsInDesignDocView alloc] initWithDatabaseName:@"  "
                                                                 designDocId:ICDREQUESTDOCSINDESIGNDOCVIEWTESTS_DESIGNDOCID
                                                                    viewname:ICDREQUESTDOCSINDESIGNDOCVIEWTESTS_VIEWNAME],
                 @"Only spaces is equal to an empty database name");
}

- (void)testInitWithoutADesignDocIdFails
{
    XCTAssertNil([[ICDRequestDocsInDesignDocView alloc] initWithDatabaseName:ICDREQUESTDOCSINDESIGNDOCVIEWTESTS_DBNAME
                                                                 designDocId:nil
                                                                    viewname:ICDREQUESTDOCSINDESIGNDOCVIEWTESTS_VIEWNAME],
                 @"Database, design doc id and viewname are required to find a design document");
}

- (void)testInitWithAnIncorrectDesignDocFails
{
    XCTAssertNil([[ICDRequestDocsInDesignDocView alloc] initWithDatabaseName:ICDREQUESTDOCSINDESIGNDOCVIEWTESTS_DBNAME
                                                                 designDocId:@"designDocId"
                                                                    viewname:ICDREQUESTDOCSINDESIGNDOCVIEWTESTS_VIEWNAME],
                 @"A valid design doc id starts with %@", kNSStringCloudantDesignDocIdPrefix);
}

- (void)testInitWithoutAViewnameFails
{
    XCTAssertNil([[ICDRequestDocsInDesignDocView alloc] initWithDatabaseName:ICDREQUESTDOCSINDESIGNDOCVIEWTESTS_DBNAME
                                                                 designDocId:ICDREQUESTDOCSINDESIGNDOCVIEWTESTS_DESIGNDOCID
                                                                    viewname:nil],
                 @"Database, design doc id and viewname are required to find a design document");
}

- (void)testInitWithEmptyViewnameFails
{
    XCTAssertNil([[ICDRequestDocsInDesignDocView alloc] initWithDatabaseName:ICDREQUESTDOCSINDESIGNDOCVIEWTESTS_DBNAME
                                                                 designDocId:ICDREQUESTDOCSINDESIGNDOCVIEWTESTS_DESIGNDOCID
                                                                    viewname:@""],
                 @"An empty name is not a valid viewname");
}

- (void)testInitWithViewnameEqualToSpacesFails
{
    XCTAssertNil([[ICDRequestDocsInDesignDocView alloc] initWithDatabaseName:ICDREQUESTDOCSINDESIGNDOCVIEWTESTS_DBNAME
                                                                 designDocId:ICDREQUESTDOCSINDESIGNDOCVIEWTESTS_DESIGNDOCID
                                                                    viewname:@"  "],
                 @"Only spaces is equal to an empty viewname");
}

- (void)testExecuteRequestCallCompletionHandlerIfItSucceeds
{
    self.mockObjectManager.successResult = self.mockMappingResult;
    
    __block BOOL wasCompletionHandlerExecuted = NO;
    [self.docsInDesignDocViewRequest asynExecuteRequestWithObjectManager:self.mockObjectManager completionHandler:^{
        wasCompletionHandlerExecuted = YES;
    }];
    
    XCTAssertTrue(wasCompletionHandlerExecuted, @"CompletionHandler must be executed by the request always");
}

- (void)testExecuteRequestCallCompletionHandlerIfItFails
{
    self.mockObjectManager.failureResult = (NSError *)@"error";
    
    __block BOOL wasCompletionHandlerExecuted = NO;
    [self.docsInDesignDocViewRequest asynExecuteRequestWithObjectManager:self.mockObjectManager completionHandler:^{
        wasCompletionHandlerExecuted = YES;
    }];
    
    XCTAssertTrue(wasCompletionHandlerExecuted, @"CompletionHandler must be executed by the request always");
}

@end
