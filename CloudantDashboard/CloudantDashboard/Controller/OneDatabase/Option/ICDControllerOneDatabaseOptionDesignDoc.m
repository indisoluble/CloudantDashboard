//
//  ICDControllerOneDatabaseOptionDesignDoc.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 18/01/2015.
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

#import "ICDControllerOneDatabaseOptionDesignDoc.h"

#import "ICDControllerDesignDocViewsTVC.h"

#import "ICDControllerOneDatabaseOptionCommon.h"



#define ICDCONTROLLERONEDATABASEOPTIONDESIGNDOC_SEGUE   @"showDesignDoc"



@interface ICDControllerOneDatabaseOptionDesignDoc ()

@property (strong, nonatomic, readonly) NSString *designDocId;
@property (strong, nonatomic, readonly) NSString *databaseNameOrNil;
@property (strong, nonatomic, readonly) id<ICDNetworkManagerProtocol> networkManagerOrNil;

@end



@implementation ICDControllerOneDatabaseOptionDesignDoc

#pragma mark - Init object
- (id)initWithDesignDocId:(NSString *)designDocId
             databaseName:(NSString *)databaseNameOrNil
           networkManager:(id<ICDNetworkManagerProtocol>)networkManagerOrNil
{
    self = [super init];
    if (self)
    {
        if (!designDocId)
        {
            self = nil;
        }
        else
        {
            _designDocId = designDocId;
            _databaseNameOrNil = databaseNameOrNil;
            _networkManagerOrNil = networkManagerOrNil;
        }
    }
    
    return self;
}


#pragma mark - ICDControllerOneDatabaseOptionProtocol methods
- (UITableViewCell *)cellForTableView:(UITableView *)tableView
                          atIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [ICDControllerOneDatabaseOptionCommon dequeueCommonCellFromTableView:tableView
                                                                                     atIndexPath:indexPath];
    cell.textLabel.text = self.designDocId;
    
    return cell;
}

- (NSString *)segueIdentifier
{
    return ICDCONTROLLERONEDATABASEOPTIONDESIGNDOC_SEGUE;
}

- (void)configureViewController:(UIViewController *)viewController
{
    ICDControllerDesignDocViewsTVC *designDocViewsTVC = (ICDControllerDesignDocViewsTVC *)viewController;
    
    [designDocViewsTVC useNetworkManager:self.networkManagerOrNil
                            databaseName:self.databaseNameOrNil
                             designDocId:self.designDocId];
}


#pragma mark - Public class methods
+ (instancetype)optionWithDesignDocId:(NSString *)designDocId
                         databaseName:(NSString *)databaseNameOrNil
                       networkManager:(id<ICDNetworkManagerProtocol>)networkManagerOrNil
{
    return [[[self class] alloc] initWithDesignDocId:designDocId
                                        databaseName:databaseNameOrNil
                                      networkManager:networkManagerOrNil];
}

@end
