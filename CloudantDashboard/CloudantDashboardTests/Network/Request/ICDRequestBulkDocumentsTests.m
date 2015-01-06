//
//  ICDRequestBulkDocumentsTests.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 06/01/2015.
//  Copyright (c) 2015 Enrique de la Torre. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "ICDRequestBulkDocuments.h"

#import "ICDMockRKObjectManager.h"



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
    self.bulkDocumentsRequest = [[ICDRequestBulkDocuments alloc] initWithDatabaseName:@"dbName"];
    
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
    XCTAssertNil([[ICDRequestBulkDocuments alloc] initWithDatabaseName:nil],
                 @"we need a database name to know where to create the documents");
}

- (void)testInitWithEmptyDatabaseNameFails
{
    XCTAssertNil([[ICDRequestBulkDocuments alloc] initWithDatabaseName:@""],
                 @"An empty name is not a valid database name");
}

- (void)testInitWithDatabaseNameEqualToSpacesFails
{
    XCTAssertNil([[ICDRequestBulkDocuments alloc] initWithDatabaseName:@"  "],
                 @"Only spaces is equal to an empty database name");
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
