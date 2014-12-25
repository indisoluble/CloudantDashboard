//
//  ICDRequestDocumentTests.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 23/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "ICDRequestDocument.h"



@interface ICDRequestDocumentTests : XCTestCase

@end



@implementation ICDRequestDocumentTests

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
    XCTAssertNil([[ICDRequestDocument alloc] init],
                 @"Database and document id are required to find a document");
}

- (void)testInitWithoutADatabaseNameFails
{
    XCTAssertNil([[ICDRequestDocument alloc] initWithDatabaseName:nil documentId:@"documentId"],
                 @"Database and document id are required to find a document");
}

- (void)testInitWithoutADocumentIdFails
{
    XCTAssertNil([[ICDRequestDocument alloc] initWithDatabaseName:@"databaseName" documentId:nil],
                 @"Database and document id are required to find a document");
}

- (void)testInitWithEmptyDatabaseNameFails
{
    XCTAssertNil([[ICDRequestDocument alloc] initWithDatabaseName:@"" documentId:@"documentId"],
                 @"An empty name is not a valid database name");
}

- (void)testInitWithDatabaseNameEqualToSpacesFails
{
    XCTAssertNil([[ICDRequestDocument alloc] initWithDatabaseName:@"  " documentId:@"documentId"],
                 @"Only spaces is equal to an empty database name");
}

- (void)testInitWithEmptyDocumentIdFails
{
    XCTAssertNil([[ICDRequestDocument alloc] initWithDatabaseName:@"databaseName" documentId:@""],
                 @"An empty id is not a valid id for a document");
}

- (void)testInitWithDocumentIdEqualToSpacesFails
{
    XCTAssertNil([[ICDRequestDocument alloc] initWithDatabaseName:@"databaseName" documentId:@"  "],
                 @"Only spaces is equal to an empty document id");
}

@end
