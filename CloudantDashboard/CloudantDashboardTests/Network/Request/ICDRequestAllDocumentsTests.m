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



@interface ICDRequestAllDocumentsTests : XCTestCase

@end



@implementation ICDRequestAllDocumentsTests

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
    XCTAssertNil([[ICDRequestAllDocuments alloc] init],
                 @"Without a name, we can not request the documents in a database");
}

- (void)testInitWithoutADatabaseNameFails
{
    XCTAssertNil([[ICDRequestAllDocuments alloc] initWithDatabaseName:nil],
                 @"Without a name, we can not request the documents in a database");
}

- (void)testInitWithEmptyDatabaseNameFails
{
    XCTAssertNil([[ICDRequestAllDocuments alloc] initWithDatabaseName:@""],
                 @"An empty name is not a valid databae name");
}

- (void)testInitWithDatabaseNameEqualToSpacesFails
{
    XCTAssertNil([[ICDRequestAllDocuments alloc] initWithDatabaseName:@"  "],
                 @"Only spaces is equal to an empty database name");
}

@end
