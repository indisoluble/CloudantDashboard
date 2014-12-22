//
//  ICDNetworkManagerTests.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 22/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "ICDNetworkManager.h"

#import "ICDMockRequest.h"



@interface ICDNetworkManagerTests : XCTestCase

@property (strong, nonatomic) ICDNetworkManager *networkManager;

@end



@implementation ICDNetworkManagerTests

- (void)setUp
{
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.networkManager = [[ICDNetworkManager alloc] initWithObjectManager:@"objectManager"];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    self.networkManager = nil;
    
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

- (void)testExecuteSameInstanceTwiceOnlyConfigureManagerOnce
{
    [ICDMockRequest resetConfigureCounter];
    
    ICDMockRequest *request = [[ICDMockRequest alloc] init];
    [self.networkManager executeRequest:request];
    [self.networkManager executeRequest:request];
    
    XCTAssertEqual([ICDMockRequest configureCounter], 1, @"Each type of request has to be configured only once in the manager");
}

- (void)testExecuteSameTypeOfRequestTwiceOnlyConfigureManagerOnce
{
    [ICDMockRequest resetConfigureCounter];
    
    [self.networkManager executeRequest:[[ICDMockRequest alloc] init]];
    [self.networkManager executeRequest:[[ICDMockRequest alloc] init]];
    
    XCTAssertEqual([ICDMockRequest configureCounter], 1, @"Each type of request has to be configured only once in the manager");
}

@end
