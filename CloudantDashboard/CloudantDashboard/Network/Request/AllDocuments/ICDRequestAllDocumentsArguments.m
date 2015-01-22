//
//  ICDRequestAllDocumentsArguments.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 17/01/2015.
//  Copyright (c) 2015 Enrique de la Torre. All rights reserved.
//

#import "ICDRequestAllDocumentsArguments.h"

#import "NSString+CloudantDesignDocId.h"



@interface ICDRequestAllDocumentsArguments ()

@end



@implementation ICDRequestAllDocumentsArguments

#pragma mark - Public class methods
+ (ICDRequestAllDocumentsArguments *)allDesignDocs
{
    ICDRequestAllDocumentsArguments *arguments = [[ICDRequestAllDocumentsArguments alloc] init];
    arguments.startkey = [NSString stringWithFormat:@"\"%@\"", kNSStringCloudantDesignDocIdPrefix];
    arguments.endkey = [NSString stringWithFormat:@"\"%@0\"", kNSStringCloudantDesignDocIdPrefix];
    
    return arguments;
}

@end
