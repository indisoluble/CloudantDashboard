//
//  ICDRequestDeleteDatabaseTests.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 24/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "ICDRequestDeleteDatabase.h"



@interface ICDRequestDeleteDatabaseTests : XCTestCase

@end



@implementation ICDRequestDeleteDatabaseTests

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

- (void)testSimpleInitFails
{
    XCTAssertNil([[ICDRequestDeleteDatabase alloc] init],
                 @"Without a name there is no way to know the database to delete");
}

- (void)testInitWithoutADatabaseNameFails
{
    XCTAssertNil([[ICDRequestDeleteDatabase alloc] initWithDatabaseName:nil],
                 @"Without a name there is no way to know the database to delete");
}

@end
