//
//  ICDControllerOneDatabaseOptionAllDocsTests.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 11/01/2015.
//  Copyright (c) 2015 Enrique de la Torre. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "ICDControllerOneDatabaseOptionAllDocs.h"

#import "ICDControllerDocumentsTVC.h"



@interface ICDControllerOneDatabaseOptionAllDocsTests : XCTestCase

@property (strong, nonatomic) ICDControllerOneDatabaseOptionAllDocs *option;

@end



@implementation ICDControllerOneDatabaseOptionAllDocsTests

- (void)setUp
{
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.option = [[ICDControllerOneDatabaseOptionAllDocs alloc] init];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    self.option = nil;
    
    [super tearDown];
}

- (void)testConfigureViewControllerRaisesExceptionWithWrongParameter
{
    XCTAssertThrows([self.option configureViewController:(UIViewController *)@""],
                    @"Pass a valid parameter: %@", [ICDControllerDocumentsTVC class]);
}

@end
