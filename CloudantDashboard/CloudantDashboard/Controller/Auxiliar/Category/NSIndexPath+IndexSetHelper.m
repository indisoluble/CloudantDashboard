//
//  NSIndexPath+IndexSetHelper.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 06/01/2015.
//  Copyright (c) 2015 Enrique de la Torre. All rights reserved.
//

#import "NSIndexPath+IndexSetHelper.h"



@implementation NSIndexPath (IndexSetHelper)

#pragma mark - Public class methods
+ (NSArray *)indexPathsForRows:(NSIndexSet *)rows inSection:(NSInteger)section
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[rows count]];
    
    [rows enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [array addObject:[NSIndexPath indexPathForRow:idx inSection:section]];
    }];
    
    return array;
}

@end
