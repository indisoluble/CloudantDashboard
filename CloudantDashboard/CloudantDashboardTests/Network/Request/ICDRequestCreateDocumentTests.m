//
//  ICDRequestCreateDocumentTests.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 25/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "ICDRequestCreateDocument.h"



@interface ICDRequestCreateDocumentTests : XCTestCase

@end



@implementation ICDRequestCreateDocumentTests

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
    XCTAssertNil([[ICDRequestCreateDocument alloc] init],
                 @"we need a database name to know where to create the document");
}

- (void)testInitWithoutADatabaseNameFails
{
    XCTAssertNil([[ICDRequestCreateDocument alloc] initWithDatabaseName:nil],
                 @"we need a database name to know where to create the document");
}

- (void)testInitWithEmptyDatabaseNameFails
{
    XCTAssertNil([[ICDRequestCreateDocument alloc] initWithDatabaseName:@""],
                 @"An empty name is not a valid database name");
}

- (void)testInitWithDatabaseNameEqualToSpacesFails
{
    XCTAssertNil([[ICDRequestCreateDocument alloc] initWithDatabaseName:@"  "],
                 @"Only spaces is equal to an empty database name");
}

@end
