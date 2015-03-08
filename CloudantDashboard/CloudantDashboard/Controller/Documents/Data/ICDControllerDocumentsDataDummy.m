//
//  ICDControllerDocumentsDataDummy.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 23/01/2015.
//  Copyright (c) 2015 Enrique de la Torre. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file
//  except in compliance with the License. You may obtain a copy of the License at
//    http://www.apache.org/licenses/LICENSE-2.0
//  Unless required by applicable law or agreed to in writing, software distributed under the
//  License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
//  either express or implied. See the License for the specific language governing permissions
//  and limitations under the License.
//

#import "ICDControllerDocumentsDataDummy.h"

#import "ICDNetworkManagerFactory.h"



@interface ICDControllerDocumentsDataDummy ()

@end



@implementation ICDControllerDocumentsDataDummy

#pragma mark - Synthesize properties
@synthesize databaseNameOrNil = _databaseNameOrNil;
@synthesize networkManager = _networkManager;

@synthesize isRefreshingDocs = _isRefreshingDocs;

@synthesize delegate = _delegate;


#pragma mark - Init object
- (id)init
{
    self = [super init];
    if (self)
    {
        _databaseNameOrNil = nil;
        _networkManager = [ICDNetworkManagerFactory networkManager];
        
        _isRefreshingDocs = NO;
    }
    
    return self;
}


#pragma mark - ICDControllerDocumentsDataProtocol methods
- (NSInteger)numberOfDocuments
{
    return 0;
}

- (ICDModelDocument *)documentAtIndex:(NSUInteger)index
{
    return nil;
}

- (BOOL)asyncRefreshDocs
{
    return NO;
}

@end
