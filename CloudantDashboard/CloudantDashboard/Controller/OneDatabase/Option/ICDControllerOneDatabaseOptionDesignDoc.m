//
//  ICDControllerOneDatabaseOptionDesignDoc.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 18/01/2015.
//  Copyright (c) 2015 Enrique de la Torre. All rights reserved.
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
