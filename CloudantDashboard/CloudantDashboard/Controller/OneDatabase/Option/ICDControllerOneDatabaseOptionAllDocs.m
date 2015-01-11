//
//  ICDControllerOneDatabaseOptionAllDocs.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 11/01/2015.
//  Copyright (c) 2015 Enrique de la Torre. All rights reserved.
//

#import "ICDControllerOneDatabaseOptionAllDocs.h"

#import "ICDControllerDocumentsTVC.h"



#define ICDCONTROLLERONEDATABASEOPTIONALLDOCS_SEGUE @"showAllDocuments"



NSString * const kICDControllerOneDatabaseOptionAllDocsCellID = @"databaseOptionCell";



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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kICDControllerOneDatabaseOptionAllDocsCellID
                                                            forIndexPath:indexPath];
    cell.textLabel.text = NSLocalizedString(@"All Documents", @"All Documents");
    
    return cell;
}

- (NSString *)segueIdentifier
{
    return ICDCONTROLLERONEDATABASEOPTIONALLDOCS_SEGUE;
}

- (void)configureViewController:(UIViewController *)viewController
{
    ICDControllerDocumentsTVC *documentsTVC = (ICDControllerDocumentsTVC *)viewController;
    
    [documentsTVC useNetworkManager:self.networkManagerOrNil databaseName:self.dbNameOrNil];
}


#pragma mark - Public class methods
+ (instancetype)optionWithDatabaseName:(NSString *)databaseNameOrNil
                        networkManager:(id<ICDNetworkManagerProtocol>)networkManagerOrNil
{
    return [[[self class] alloc] initWithDatabaseName:databaseNameOrNil networkManager:networkManagerOrNil];
}

@end
