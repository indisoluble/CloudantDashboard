//
//  ICDNetworkManagerTests.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 22/12/2014.
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

#import "ICDNetworkManager.h"

#import "ICDMockRequest.h"



@interface ICDNetworkManagerTests : XCTestCase

@property (strong, nonatomic) ICDNetworkManager *manager;

@property (strong, nonatomic) ICDMockRequest *mockRequest;

@end



@implementation ICDNetworkManagerTests

- (void)setUp
{
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.manager = [[ICDNetworkManager alloc] initWithObjectManager:@"manager"];
    
    self.mockRequest = [[ICDMockRequest alloc] init];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    
    [super tearDown];
}

- (void)testSimpleInitFail
{
    XCTAssertNil([[ICDNetworkManager alloc] init], @"'init' is not valid");
}

- (void)testInitWithoutManagerReturnNil
{
    XCTAssertNil([[ICDNetworkManager alloc] initWithObjectManager:nil], @"No request can be executed if there is not a manager");
}

- (void)testAsyncExecuteRequestSucceedsIfPreviousRequestIsCompleted
{
    self.mockRequest.doExecuteCompletionHandler = YES;
    
    [self.manager asyncExecuteRequest:self.mockRequest];
    
    XCTAssertTrue([self.manager asyncExecuteRequest:self.mockRequest], @"If the previous request is completed, the next one should be executed straight away");
}

- (void)testAsyncExecuteRequestSuccessIfThereIsAnotherRequestOnGoing
{
    self.mockRequest.doExecuteCompletionHandler = NO;
    
    [self.manager asyncExecuteRequest:self.mockRequest];
    
    XCTAssertTrue([self.manager asyncExecuteRequest:self.mockRequest], @"If there is another request on going, the new one is scheduled");
}

@end
