//
//  ICDRequestAddRevisionTests.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 28/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "ICDRequestAddRevision.h"

#import "NSDictionary+CloudantSpecialKeys.h"



@interface ICDRequestAddRevisionTests : XCTestCase

@end



@implementation ICDRequestAddRevisionTests

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
    XCTAssertNil([[ICDRequestAddRevision alloc] init],
                 @"A revision can not be created if we don't know the database name and document id, as well as the data to add to the revision");
}

- (void)testInitWithoutADatabaseNameFails
{
    XCTAssertNil([[ICDRequestAddRevision alloc] initWithDatabaseName:nil documentId:@"docId" documentRev:@"docRev" documentData:@{}],
                 @"The database name is required to find the document");
}

- (void)testInitWithEmptyDatabaseNameFails
{
    XCTAssertNil([[ICDRequestAddRevision alloc] initWithDatabaseName:@"" documentId:@"docId" documentRev:@"docRev" documentData:@{}],
                 @"The database name is required to find the document");
}

- (void)testInitWithoutADocumentIdFails
{
    XCTAssertNil([[ICDRequestAddRevision alloc] initWithDatabaseName:@"dbName" documentId:nil documentRev:@"docRev" documentData:@{}],
                 @"The document id is require to find the document");
}

- (void)testInitWithEmptyDocumentIdFails
{
    XCTAssertNil([[ICDRequestAddRevision alloc] initWithDatabaseName:@"dbName" documentId:@"" documentRev:@"docRev" documentData:@{}],
                 @"The document id is require to find the document");
}

- (void)testInitWithoutADocumentRevFails
{
    XCTAssertNil([[ICDRequestAddRevision alloc] initWithDatabaseName:@"dbName" documentId:@"docId" documentRev:nil documentData:@{}],
                 @"The document rev is require to find the document");
}

- (void)testInitWithEmptyDocumentRevFails
{
    XCTAssertNil([[ICDRequestAddRevision alloc] initWithDatabaseName:@"dbName" documentId:@"docId" documentRev:@"" documentData:@{}],
                 @"The document rev is require to find the document");
}

- (void)testInitWithoutDocumentDataFails
{
    XCTAssertNil([[ICDRequestAddRevision alloc] initWithDatabaseName:@"dbName" documentId:@"docId" documentRev:@"docRev" documentData:nil],
                 @"If not data is provided, there is nothing to add to the document");
}

- (void)testInitWithADocumentIdInDocumentDataFails
{
    NSDictionary *data = @{kNSDictionaryCloudantSpecialKeysDocumentId: @"docId"};
    
    XCTAssertNil([[ICDRequestAddRevision alloc] initWithDatabaseName:@"dbName" documentId:@"docId" documentRev:@"docRev" documentData:data],
                 @"The documentID is only provided as a parameter");
}

- (void)testInitWithADocumentRevInDocumemtDataFails
{
    NSDictionary *data = @{kNSDictionaryCloudantSpecialKeysDocumentRev: @"docRev"};
    
    XCTAssertNil([[ICDRequestAddRevision alloc] initWithDatabaseName:@"dbName" documentId:@"docId" documentRev:@"docRev" documentData:data],
                 @"A revision number is not required becuase we want to create a new one");
}

@end
