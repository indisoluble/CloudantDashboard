//
//  NSDictionary+CloudantSpecialKeys.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 28/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file
//  except in compliance with the License. You may obtain a copy of the License at
//    http://www.apache.org/licenses/LICENSE-2.0
//  Unless required by applicable law or agreed to in writing, software distributed under the
//  License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
//  either express or implied. See the License for the specific language governing permissions
//  and limitations under the License.
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
