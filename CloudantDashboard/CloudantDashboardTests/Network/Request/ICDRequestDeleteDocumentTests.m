//
//  ICDRequestDeleteDocumentTests.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 26/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "ICDRequestDeleteDocument.h"



@interface ICDRequestDeleteDocumentTests : XCTestCase

@end



@implementation ICDRequestDeleteDocumentTests

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
    XCTAssertNil([[ICDRequestDeleteDocument alloc] init],
                 @"Document and database of the document are required to delete a document");
}

- (void)testInitWithoutADatabaseNameFails
{
    XCTAssertNil([[ICDRequestDeleteDocument alloc] initWithDatabaseName:nil documentId:@"documentId" documentRev:@"documentRev"],
                 @"Witbout a database, we do not know where to look for the document");
}

- (void)testInitWithoutADocumentIdFails
{
    XCTAssertNil([[ICDRequestDeleteDocument alloc] initWithDatabaseName:@"databaseName" documentId:nil documentRev:@"documentRev"],
                 @"A document can not be found without an id");
}

- (void)testInitWithoutADocumentRevFails
{
    XCTAssertNil([[ICDRequestDeleteDocument alloc] initWithDatabaseName:@"databaseName" documentId:@"documentId" documentRev:nil],
                 @"A document can not be found without an id");
}

- (void)testInitWithEmptyDatabaseNameFails
{
    XCTAssertNil([[ICDRequestDeleteDocument alloc] initWithDatabaseName:@"" documentId:@"documentId" documentRev:@"documentRev"],
                 @"Witbout a database, we do not know where to look for the document");
}

- (void)testInitWithEmptyDocumentIdFails
{
    XCTAssertNil([[ICDRequestDeleteDocument alloc] initWithDatabaseName:@"databaseName" documentId:@"" documentRev:@"documentRev"],
                 @"A document can not be found without an id");
}

- (void)testInitWithEmptyDocumentRevFails
{
    XCTAssertNil([[ICDRequestDeleteDocument alloc] initWithDatabaseName:@"databaseName" documentId:@"documentId" documentRev:@""],
                 @"A document can not be found without an id");
}

- (void)testInitWithDatabaseNameEqualToSpacesFails
{
    XCTAssertNil([[ICDRequestDeleteDocument alloc] initWithDatabaseName:@"  " documentId:@"documentId" documentRev:@"documentRev"],
                 @"Witbout a database, we do not know where to look for the document");
}

- (void)testInitWithDocumentIdToSpacesFails
{
    XCTAssertNil([[ICDRequestDeleteDocument alloc] initWithDatabaseName:@"databaseName" documentId:@"  " documentRev:@"documentRev"],
                 @"A document can not be found without an id");
}

- (void)testInitWithDocumentRevToSpacesFails
{
    XCTAssertNil([[ICDRequestDeleteDocument alloc] initWithDatabaseName:@"databaseName" documentId:@"documentId" documentRev:@"  "],
                 @"A document can not be found without an id");
}

@end
