//
//  NSString+CloudantDesignDocId.h
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 21/01/2015.
//  Copyright (c) 2015 Enrique de la Torre. All rights reserved.
//

#import <Foundation/Foundation.h>



extern NSString * const kNSStringCloudantDesignDocIdPrefix;



@interface NSString (CloudantDesignDocId)

- (BOOL)isDesignDocId;

+ (NSString *)designDocIdWithId:(NSString *)oneId;

@end
