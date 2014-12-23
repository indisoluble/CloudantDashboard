//
//  ICDRequestAllDocumentsForADatabaseTests.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 23/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "ICDRequestAllDocumentsForADatabase.h"



@interface ICDRequestAllDocumentsForADatabaseTests : XCTestCase

@end



@implementation ICDRequestAllDocumentsForADatabaseTests

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
    XCTAssertNil([[ICDRequestAllDocumentsForADatabase alloc] init],
                 @"Without a name, we can not request the documents in a database");
}

- (void)testInitWithoutADatabaseNameFails
{
    XCTAssertNil([[ICDRequestAllDocumentsForADatabase alloc] initWithDatabaseName:nil],
                 @"Without a name, we can not request the documents in a database");
}

@end
