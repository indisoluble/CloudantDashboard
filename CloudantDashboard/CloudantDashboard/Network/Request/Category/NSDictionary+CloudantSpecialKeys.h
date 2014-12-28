//
//  NSDictionary+CloudantSpecialKeys.h
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 28/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import <Foundation/Foundation.h>



extern NSString * const kNSDictionaryCloudantSpecialKeysDocumentId;
extern NSString * const kNSDictionaryCloudantSpecialKeysDocumentRev;



@interface NSDictionary (CloudantSpecialKeys)

- (BOOL)containAnyCloudantSpecialKeys;

@end
