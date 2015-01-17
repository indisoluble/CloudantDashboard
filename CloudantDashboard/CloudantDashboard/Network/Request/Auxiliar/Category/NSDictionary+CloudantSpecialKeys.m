//
//  NSDictionary+CloudantSpecialKeys.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 28/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import "NSDictionary+CloudantSpecialKeys.h"



NSString * const kNSDictionaryCloudantSpecialKeysDocumentId = @"_id";
NSString * const kNSDictionaryCloudantSpecialKeysDocumentRev = @"_rev";



@implementation NSDictionary (CloudantSpecialKeys)

#pragma mark - Public methods
- (BOOL)containAnyCloudantSpecialKeys
{
    return ([self objectForKey:kNSDictionaryCloudantSpecialKeysDocumentId] ||
            [self objectForKey:kNSDictionaryCloudantSpecialKeysDocumentRev]);
}

- (NSMutableDictionary *)dictionaryWithoutCloudantSpecialKeys
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:self];
    [dictionary removeObjectForKey:kNSDictionaryCloudantSpecialKeysDocumentId];
    [dictionary removeObjectForKey:kNSDictionaryCloudantSpecialKeysDocumentRev];
    
    return dictionary;
}

@end
