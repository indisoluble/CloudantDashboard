//
//  ICDControllerDesignDocViewsCellCreatorShowDocuments.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 25/01/2015.
//  Copyright (c) 2015 Enrique de la Torre. All rights reserved.
//

#import "ICDControllerDesignDocViewsCellCreatorShowDocuments.h"

#import "ICDControllerDocumentsTVC.h"
#import "ICDControllerDocumentsDataDocsInDesignDocView.h"



NSString * const kICDControllerDesignDocViewsCellCreatorShowDocumentsCellID = @"designDocViewCell";



@interface ICDControllerDesignDocViewsCellCreatorShowDocuments ()

@property (strong, nonatomic) id<ICDNetworkManagerProtocol> networkManagerOrNil;
@property (strong, nonatomic) NSString *databaseNameOrNil;
@property (strong, nonatomic) NSString *designDocIdOrNil;
@property (strong, nonatomic) NSString *viewnameOrNil;
@property (assign, nonatomic) BOOL allowSelection;

@end



@implementation ICDControllerDesignDocViewsCellCreatorShowDocuments

#pragma mark - Init object
- (id)init
{
    return [self initWithNetworkManager:nil
                           databaseName:nil
                            designDocId:nil
                               viewname:nil
                         allowSelection:NO];
}

- (id)initWithNetworkManager:(id<ICDNetworkManagerProtocol>)networkManagerOrNil
                databaseName:(NSString *)databaseNameOrNil
                 designDocId:(NSString *)designDocIdOrNil
                    viewname:(NSString *)viewnameOrNil
              allowSelection:(BOOL)allowSelection
{
    self = [super init];
    if (self)
    {
        _networkManagerOrNil = networkManagerOrNil;
        _databaseNameOrNil = databaseNameOrNil;
        _designDocIdOrNil = designDocIdOrNil;
        _viewnameOrNil = viewnameOrNil;
        _allowSelection = allowSelection;
    }
    
    return self;
}


#pragma mark - ICDControllerDesignDocViewsCellCreatorProtocol methods
- (UITableViewCell *)cellForTableView:(UITableView *)tableView
                          atIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kICDControllerDesignDocViewsCellCreatorShowDocumentsCellID
                                                            forIndexPath:indexPath];
    cell.textLabel.text = (self.viewnameOrNil ? self.viewnameOrNil : @"");
    
    return cell;
}

- (BOOL)canSelectCell
{
    return self.allowSelection;
}

- (void)configureViewController:(UIViewController *)viewController
{
    ICDControllerDocumentsTVC *documentsTVC = (ICDControllerDocumentsTVC *)viewController;
    ICDControllerDocumentsDataDocsInDesignDocView *viewData = nil;
    
    documentsTVC.title = (self.viewnameOrNil ? self.viewnameOrNil : @"");
    
    viewData = [[ICDControllerDocumentsDataDocsInDesignDocView alloc] initWithDatabaseName:self.databaseNameOrNil
                                                                               designDocId:self.designDocIdOrNil
                                                                                  viewname:self.viewnameOrNil
                                                                            networkManager:self.networkManagerOrNil];
    [documentsTVC useData:viewData];
}

@end
