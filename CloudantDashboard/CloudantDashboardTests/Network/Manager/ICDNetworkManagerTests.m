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



@interface ICDNetworkManagerTests : XCTestCase

@end



@implementation ICDNetworkManagerTests

- (void)setUp
{
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
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

@end
