//
//  ICDRequestDocsInDesignDocView.h
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 23/01/2015.
//  Copyright (c) 2015 Enrique de la Torre. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ICDRequestProtocol.h"

#import "ICDRequestDocsInDesignDocViewDelegate.h"



@interface ICDRequestDocsInDesignDocView : NSObject <ICDRequestProtocol>

@property (weak, nonatomic) id<ICDRequestDocsInDesignDocViewDelegate> delegate;

- (id)initWithDatabaseName:(NSString *)dbName
               designDocId:(NSString *)designDocId
                  viewname:(NSString *)viewname;

@end
