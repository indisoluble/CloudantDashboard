//
//  ICDControllerOneDatabaseOptionAllDesignDocs.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 15/01/2015.
//  Copyright (c) 2015 Enrique de la Torre. All rights reserved.
//

#import "ICDControllerOneDatabaseOptionAllDesignDocs.h"

#import "ICDControllerDocumentsTVC.h"

#import "ICDControllerDocumentsDataAllDesignDocs.h"

#import "ICDControllerOneDatabaseOptionCommon.h"



@interface ICDControllerOneDatabaseOptionAllDesignDocs ()

@property (strong, nonatomic, readonly) NSString *dbNameOrNil;
@property (strong, nonatomic, readonly) id<ICDNetworkManagerProtocol> networkManagerOrNil;

@end



@implementation ICDControllerOneDatabaseOptionAllDesignDocs

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
    cell.textLabel.text = NSLocalizedString(@"All Design Docs", @"All Design Docs");
    
    return cell;
}

- (NSString *)segueIdentifier
{
    return [ICDControllerOneDatabaseOptionCommon commonSegue];
}

- (void)configureViewController:(UIViewController *)viewController
{
    ICDControllerDocumentsTVC *documentsTVC = (ICDControllerDocumentsTVC *)viewController;
    ICDControllerDocumentsDataAllDesignDocs *data = [[ICDControllerDocumentsDataAllDesignDocs alloc] initWithDatabaseName:self.dbNameOrNil
                                                                                                           networkManager:self.networkManagerOrNil];
    
    documentsTVC.title = NSLocalizedString(@"All Design Docs", @"All Design Docs");
    [documentsTVC useData:data];
}


#pragma mark - Public class methods
+ (instancetype)optionWithDatabaseName:(NSString *)databaseNameOrNil
                        networkManager:(id<ICDNetworkManagerProtocol>)networkManagerOrNil
{
    return [[[self class] alloc] initWithDatabaseName:databaseNameOrNil networkManager:networkManagerOrNil];
}

@end
