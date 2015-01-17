//
//  ICDRequestAllDocumentsArguments.h
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 17/01/2015.
//  Copyright (c) 2015 Enrique de la Torre. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface ICDRequestAllDocumentsArguments : NSObject

@property (strong, nonatomic) NSString *startkey;
@property (strong, nonatomic) NSString *endkey;

+ (ICDRequestAllDocumentsArguments *)allDesignDocs;

@end