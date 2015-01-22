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

@property (strong, nonatomic, readonly) ICDModelDocument *designDoc;
@property (strong, nonatomic, readonly) NSString *databaseNameOrNil;
@property (strong, nonatomic, readonly) id<ICDNetworkManagerProtocol> networkManagerOrNil;

@end



@implementation ICDControllerOneDatabaseOptionDesignDoc

#pragma mark - Init object
- (id)initWithDesignDoc:(ICDModelDocument *)designDoc
           databaseName:(NSString *)databaseNameOrNil
         networkManager:(id<ICDNetworkManagerProtocol>)networkManagerOrNil
{
    self = [super init];
    if (self)
    {
        if (!designDoc)
        {
            self = nil;
        }
        else
        {
            _designDoc = designDoc;
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
    cell.textLabel.text = self.designDoc.documentId;
    
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
                               designDoc:self.designDoc];
}


#pragma mark - Public class methods
+ (instancetype)optionWithDesignDoc:(ICDModelDocument *)designDoc
                       databaseName:(NSString *)databaseNameOrNil
                     networkManager:(id<ICDNetworkManagerProtocol>)networkManagerOrNil
{
    return [[[self class] alloc] initWithDesignDoc:designDoc
                                      databaseName:databaseNameOrNil
                                    networkManager:networkManagerOrNil];
}

@end
