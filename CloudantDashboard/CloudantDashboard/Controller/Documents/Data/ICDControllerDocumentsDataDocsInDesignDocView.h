//
//  ICDControllerDocumentsDataDocsInDesignDocView.h
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 24/01/2015.
//  Copyright (c) 2015 Enrique de la Torre. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ICDControllerDocumentsDataProtocol.h"

#import "ICDModelDocument.h"
#import "ICDModelDesignDocumentView.h"



@interface ICDControllerDocumentsDataDocsInDesignDocView : NSObject <ICDControllerDocumentsDataProtocol>

- (id)initWithDatabaseName:(NSString *)databaseNameOrNil
                 designDoc:(ICDModelDocument *)designDocOrNil
             designDocView:(ICDModelDesignDocumentView *)designDocViewOrNil
            networkManager:(id<ICDNetworkManagerProtocol>)networkManagerOrNil;

@end
