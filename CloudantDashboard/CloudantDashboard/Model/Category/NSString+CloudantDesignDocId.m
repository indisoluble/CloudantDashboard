//
//  NSString+CloudantDesignDocId.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 21/01/2015.
//  Copyright (c) 2015 Enrique de la Torre. All rights reserved.
//

#import "NSString+CloudantDesignDocId.h"



NSString * const kNSStringCloudantDesignDocIdPrefix = @"_design";



@implementation NSString (CloudantDesignDocId)

#pragma mark - Public methods
- (BOOL)isDesignDocId
{
    return [self hasPrefix:[NSString completeDesignDocIdPrefix]];
}


#pragma mark - Public class methods
+ (NSString *)designDocIdWithId:(NSString *)oneId
{
    return [[NSString completeDesignDocIdPrefix] stringByAppendingString:oneId];
}


#pragma mark - Private class methods
+ (NSString *)completeDesignDocIdPrefix
{
    return [kNSStringCloudantDesignDocIdPrefix stringByAppendingString:@"/"];
}

@end
