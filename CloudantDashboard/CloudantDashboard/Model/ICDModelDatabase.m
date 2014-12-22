//
//  ICDModelDatabase.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 22/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import "ICDModelDatabase.h"



@interface ICDModelDatabase ()

@end



@implementation ICDModelDatabase

#pragma mark - NSObject methods
- (NSString *)description
{
    return [NSString stringWithFormat:@"Database name: %@", self.name];
}

@end
