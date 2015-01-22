//
//  ICDRequestDesignDocTests.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 21/01/2015.
//  Copyright (c) 2015 Enrique de la Torre. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "ICDRequestDesignDoc.h"

#import "ICDMockRKObjectManager.h"

#import "NSString+CloudantDesignDocId.h"



#define ICDREQUESTDESIGNDOCTESTS_DBNAME         @"databaseName"
#define ICDREQUESTDESIGNDOCTESTS_DESIGNDOCID    [NSString designDocIdWithId:@"designDocId"]



@interface ICDRequestDesignDocTests : XCTestCase

@property (strong, nonatomic) ICDRequestDesignDoc *designDocRequest;

@property (strong, nonatomic) ICDMockRKObjectManager *mockObjectManager;
@property (strong, nonatomic) ICDMockRKMappingResult *mockMappingResult;

@end



@implementation ICDRequestDesignDocTests

- (void)setUp
{
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.designDocRequest = [[ICDRequestDesignDoc alloc] initWithDatabaseName:ICDREQUESTDESIGNDOCTESTS_DBNAME
                                                                  designDocId:ICDREQUESTDESIGNDOCTESTS_DESIGNDOCID];
    
    self.mockObjectManager = [[ICDMockRKObjectManager alloc] init];
    
    self.mockMappingResult = [[ICDMockRKMappingResult alloc] init];
    self.mockMappingResult.firstObjectResult = @"firstObject";
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    self.mockMappingResult = nil;
    self.mockObjectManager = nil;
    
    self.designDocRequest = nil;
    
    [super tearDown];
}

- (void)testSimpleInitFails
{
    XCTAssertNil([[ICDRequestDesignDoc alloc] init],
                 @"Database and design doc id are required to find a design document");
}

- (void)testInitWithoutADatabaseNameFails
{
    XCTAssertNil([[ICDRequestDesignDoc alloc] initWithDatabaseName:nil designDocId:ICDREQUESTDESIGNDOCTESTS_DESIGNDOCID],
                 @"Database and design doc id are required to find a design document");
}

- (void)testInitWithoutADesignDocIdFails
{
    XCTAssertNil([[ICDRequestDesignDoc alloc] initWithDatabaseName:ICDREQUESTDESIGNDOCTESTS_DBNAME designDocId:nil],
                 @"Database and document id are required to find a design document");
}

- (void)testInitWithEmptyDatabaseNameFails
{
    XCTAssertNil([[ICDRequestDesignDoc alloc] initWithDatabaseName:@"" designDocId:ICDREQUESTDESIGNDOCTESTS_DESIGNDOCID],
                 @"An empty name is not a valid database name");
}

- (void)testInitWithDatabaseNameEqualToSpacesFails
{
    XCTAssertNil([[ICDRequestDesignDoc alloc] initWithDatabaseName:@"  " designDocId:ICDREQUESTDESIGNDOCTESTS_DESIGNDOCID],
                 @"Only spaces is equal to an empty database name");
}

- (void)testInitWithAnIncorrectDesignDocFails
{
    XCTAssertNil([[ICDRequestDesignDoc alloc] initWithDatabaseName:ICDREQUESTDESIGNDOCTESTS_DBNAME designDocId:@"designDocId"],
                 @"A valid design doc id starts with %@", kNSStringCloudantDesignDocIdPrefix);
}

- (void)testExecuteRequestCallCompletionHandlerIfItSucceeds
{
    self.mockObjectManager.successResult = self.mockMappingResult;
    
    __block BOOL wasCompletionHandlerExecuted = NO;
    [self.designDocRequest asynExecuteRequestWithObjectManager:self.mockObjectManager completionHandler:^{
        wasCompletionHandlerExecuted = YES;
    }];
    
    XCTAssertTrue(wasCompletionHandlerExecuted, @"CompletionHandler must be executed by the request always");
}

- (void)testExecuteRequestCallCompletionHandlerIfItFails
{
    self.mockObjectManager.failureResult = (NSError *)@"error";
    
    __block BOOL wasCompletionHandlerExecuted = NO;
    [self.designDocRequest asynExecuteRequestWithObjectManager:self.mockObjectManager completionHandler:^{
        wasCompletionHandlerExecuted = YES;
    }];
    
    XCTAssertTrue(wasCompletionHandlerExecuted, @"CompletionHandler must be executed by the request always");
}

@end
