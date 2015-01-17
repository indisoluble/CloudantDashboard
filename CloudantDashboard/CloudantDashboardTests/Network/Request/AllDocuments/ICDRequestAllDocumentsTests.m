//
//  ICDRequestAllDocumentsTests.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 23/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "ICDRequestAllDocuments.h"

#import "ICDMockRKObjectManager.h"



#define ICDREQUESTALLDOCUMENTSTESTS_DBNAME  @"dbName"



@interface ICDRequestAllDocumentsTests : XCTestCase

@property (strong, nonatomic) ICDRequestAllDocuments *allDocumentsRequest;

@property (strong, nonatomic) ICDMockRKObjectManager *mockObjectManager;
@property (strong, nonatomic) ICDMockRKMappingResult *mockMappingResult;

@end



@implementation ICDRequestAllDocumentsTests

- (void)setUp
{
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.allDocumentsRequest = [[ICDRequestAllDocuments alloc] initWithDatabaseName:ICDREQUESTALLDOCUMENTSTESTS_DBNAME
                                                                          arguments:nil];
    
    self.mockObjectManager = [[ICDMockRKObjectManager alloc] init];
    
    self.mockMappingResult = [[ICDMockRKMappingResult alloc] init];
    self.mockMappingResult.arrayResult = @[];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    self.mockMappingResult = nil;
    self.mockObjectManager = nil;
    
    self.allDocumentsRequest = nil;
    
    [super tearDown];
}

- (void)testSimpleInitFails
{
    XCTAssertNil([[ICDRequestAllDocuments alloc] init],
                 @"Without a name, we can not request the documents in a database");
}

- (void)testInitWithoutADatabaseNameFails
{
    XCTAssertNil([[ICDRequestAllDocuments alloc] initWithDatabaseName:nil  arguments:nil],
                 @"Without a name, we can not request the documents in a database");
}

- (void)testInitWithEmptyDatabaseNameFails
{
    XCTAssertNil([[ICDRequestAllDocuments alloc] initWithDatabaseName:@""  arguments:nil],
                 @"An empty name is not a valid databae name");
}

- (void)testInitWithDatabaseNameEqualToSpacesFails
{
    XCTAssertNil([[ICDRequestAllDocuments alloc] initWithDatabaseName:@"  "  arguments:nil],
                 @"Only spaces is equal to an empty database name");
}

- (void)testInitWithoutArgumentsSucceed
{
    XCTAssertNotNil(self.allDocumentsRequest, @"No argument is mandatory");
}

- (void)testInitWithArgumentsEmptySucceed
{
    ICDRequestAllDocumentsArguments *arguments = [[ICDRequestAllDocumentsArguments alloc] init];
    XCTAssertNotNil([[ICDRequestAllDocuments alloc] initWithDatabaseName:ICDREQUESTALLDOCUMENTSTESTS_DBNAME
                                                               arguments:arguments],
                    @"No argument is mandatory");
}

- (void)testExecuteRequestCallCompletionHandlerIfItSucceeds
{
    self.mockObjectManager.successResult = self.mockMappingResult;
    
    __block BOOL wasCompletionHandlerExecuted = NO;
    [self.allDocumentsRequest asynExecuteRequestWithObjectManager:self.mockObjectManager completionHandler:^{
        wasCompletionHandlerExecuted = YES;
    }];
    
    XCTAssertTrue(wasCompletionHandlerExecuted, @"CompletionHandler must be executed by the request always");
}

- (void)testExecuteRequestCallCompletionHandlerIfItFails
{
    self.mockObjectManager.failureResult = (NSError *)@"error";
    
    __block BOOL wasCompletionHandlerExecuted = NO;
    [self.allDocumentsRequest asynExecuteRequestWithObjectManager:self.mockObjectManager completionHandler:^{
        wasCompletionHandlerExecuted = YES;
    }];
    
    XCTAssertTrue(wasCompletionHandlerExecuted, @"CompletionHandler must be executed by the request always");
}

@end
