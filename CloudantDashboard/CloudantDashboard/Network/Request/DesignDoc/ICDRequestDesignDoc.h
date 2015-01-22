//
//  ICDRequestDesignDoc.h
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 20/01/2015.
//  Copyright (c) 2015 Enrique de la Torre. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ICDRequestProtocol.h"
#import "ICDRequestDesignDocDelegate.h"



@interface ICDRequestDesignDoc : NSObject <ICDRequestProtocol>

@property (weak, nonatomic) id<ICDRequestDesignDocDelegate> delegate;

- (id)initWithDatabaseName:(NSString *)dbName designDocId:(NSString *)designDocId;

@end
