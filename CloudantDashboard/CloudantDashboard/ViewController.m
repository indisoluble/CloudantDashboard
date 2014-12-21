//
//  ViewController.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 21/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import <Restkit/RestKit.h>

#import "ViewController.h"

#import "ICDAuthorizationPlist.h"



@interface ViewController ()

@end



@implementation ViewController

#pragma mark - Memory management
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}


#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    ICDAuthorizationPlist *auth = [[ICDAuthorizationPlist alloc] init];
    
    NSString *thisUsername = nil;
    NSString *thisPassword = nil;
    NSError *thisError = nil;
    BOOL success = [auth resolveUsername:&thisUsername password:&thisPassword error:&thisError];
    RKLogInfo(@"%@, %@, %i, %@", thisUsername, thisPassword, success, thisError);
}

@end
