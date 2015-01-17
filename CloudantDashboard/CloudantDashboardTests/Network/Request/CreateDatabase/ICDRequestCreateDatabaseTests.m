//
//  ICDRequestCreateDatabaseTests.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 25/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "ICDRequestCreateDatabase.h"

#import "ICDMockRKObjectManager.h"



@interface ICDRequestCreateDatabaseTests : XCTestCase

@property (strong, nonatomic) ICDRequestCreateDatabase *createDatabaseRequest;

@property (strong, nonatomic) ICDMockRKObjectManager *mockObjectManager;
@property (strong, nonatomic) ICDMockRKMappingResult *mockMappingResult;

@end



@implementation ICDRequestCreateDatabaseTests

- (void)setUp
{
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.createDatabaseRequest = [[ICDRequestCreateDatabase alloc] initWithDatabaseName:@"dbName"];
    
    self.mockObjectManager = [[ICDMockRKObjectManager alloc] init];
    
    self.mockMappingResult = [[ICDMockRKMappingResult alloc] init];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    self.mockMappingResult = nil;
    self.mockObjectManager = nil;
    
    self.createDatabaseRequest = nil;
    
    [super tearDown];
}

- (void)testSimpleInitFails
{
    XCTAssertNil([[ICDRequestCreateDatabase alloc] init], @"A database requires a name");
}

- (void)testInitWithoutADatabaseNameFails
{
    XCTAssertNil([[ICDRequestCreateDatabase alloc] initWithDatabaseName:nil], @"A database requires a name");
}

- (void)testInitWithEmptyDatabaseNameFails
{
    XCTAssertNil([[ICDRequestCreateDatabase alloc] initWithDatabaseName:@""],
                 @"A database can not be created with an empty name");
}

- (void)testInitWithDatabaseNameEqualToSpacesFails
{
    XCTAssertNil([[ICDRequestCreateDatabase alloc] initWithDatabaseName:@"  "],
                 @"Only spaces is equal to an empty database name");
}

- (void)testExecuteRequestCallCompletionHandlerIfItSucceeds
{
    self.mockObjectManager.successResult = self.mockMappingResult;
    
    __block BOOL wasCompletionHandlerExecuted = NO;
    [self.createDatabaseRequest asynExecuteRequestWithObjectManager:self.mockObjectManager completionHandler:^{
        wasCompletionHandlerExecuted = YES;
    }];
    
    XCTAssertTrue(wasCompletionHandlerExecuted, @"CompletionHandler must be executed by the request always");
}

- (void)testExecuteRequestCallCompletionHandlerIfItFails
{
    self.mockObjectManager.failureResult = (NSError *)@"error";
    
    __block BOOL wasCompletionHandlerExecuted = NO;
    [self.createDatabaseRequest asynExecuteRequestWithObjectManager:self.mockObjectManager completionHandler:^{
        wasCompletionHandlerExecuted = YES;
    }];
    
    XCTAssertTrue(wasCompletionHandlerExecuted, @"CompletionHandler must be executed by the request always");
}

@end
