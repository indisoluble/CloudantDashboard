//
//  ViewController.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 21/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import "ViewController.h"

#import "ICDAuthorizationPlist.h"

#import "ICDNetworkManager+Helper.h"

#import "ICDRequestAllDatabases.h"

#import "ICDLog.h"



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
    ICDLogInfo(@"%@, %@, %i, %@", thisUsername, thisPassword, success, thisError);
    
    ICDNetworkManager *networkManager = [ICDNetworkManager networkManagerWithUsername:thisUsername
                                                                             password:thisPassword];
    ICDRequestAllDatabases *requestAllDBs = [[ICDRequestAllDatabases alloc] init];
    [networkManager executeRequest:requestAllDBs];
}

@end
