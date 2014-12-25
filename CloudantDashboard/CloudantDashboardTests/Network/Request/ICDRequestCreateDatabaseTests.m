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



@interface ICDRequestCreateDatabaseTests : XCTestCase

@end



@implementation ICDRequestCreateDatabaseTests

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

@end
