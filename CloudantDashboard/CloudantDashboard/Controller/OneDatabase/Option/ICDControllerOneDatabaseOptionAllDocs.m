//
//  ICDControllerOneDatabaseOptionAllDocs.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 11/01/2015.
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

#import "ICDControllerOneDatabaseOptionAllDocs.h"

#import "ICDControllerDocumentsTVC.h"

#import "ICDControllerDocumentsDataAllDocuments.h"

#import "ICDControllerOneDatabaseOptionCommon.h"



@interface ICDControllerOneDatabaseOptionAllDocs ()

@property (strong, nonatomic, readonly) NSString *dbNameOrNil;
@property (strong, nonatomic, readonly) id<ICDNetworkManagerProtocol> networkManagerOrNil;

@end



@implementation ICDControllerOneDatabaseOptionAllDocs

#pragma mark - Init object
- (id)init
{
    return [self initWithDatabaseName:nil networkManager:nil];
}

- (id)initWithDatabaseName:(NSString *)databaseNameOrNil
            networkManager:(id<ICDNetworkManagerProtocol>)networkManagerOrNil;
{
    self = [super init];
    if (self)
    {
        _dbNameOrNil = databaseNameOrNil;
        _networkManagerOrNil = networkManagerOrNil;
    }
    
    return self;
}


#pragma mark - ICDControllerOneDatabaseOptionProtocol methods
- (UITableViewCell *)cellForTableView:(UITableView *)tableView
                          atIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [ICDControllerOneDatabaseOptionCommon dequeueCommonCellFromTableView:tableView
                                                                                     atIndexPath:indexPath];
    cell.textLabel.text = NSLocalizedString(@"All Documents", @"All Documents");
    
    return cell;
}

- (NSString *)segueIdentifier
{
    return [ICDControllerOneDatabaseOptionCommon commonSegue];
}

- (void)configureViewController:(UIViewController *)viewController
{
    ICDControllerDocumentsTVC *documentsTVC = (ICDControllerDocumentsTVC *)viewController;
    ICDControllerDocumentsDataAllDocuments *data = [[ICDControllerDocumentsDataAllDocuments alloc] initWithDatabaseName:self.dbNameOrNil
                                                                                                         networkManager:self.networkManagerOrNil];
    
    [documentsTVC useData:data];
}


#pragma mark - Public class methods
+ (instancetype)optionWithDatabaseName:(NSString *)databaseNameOrNil
                        networkManager:(id<ICDNetworkManagerProtocol>)networkManagerOrNil
{
    return [[[self class] alloc] initWithDatabaseName:databaseNameOrNil networkManager:networkManagerOrNil];
}

@end
