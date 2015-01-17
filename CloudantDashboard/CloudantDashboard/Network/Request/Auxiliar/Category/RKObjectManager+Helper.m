//
//  RKObjectManager+Helper.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 24/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import "RKObjectManager+Helper.h"



@implementation RKObjectManager (Helper)

#pragma mark - Public methods
- (void)removeResponseDescriptorsFromArray:(NSArray *)responseDescriptors
{
    for (RKResponseDescriptor *responseDescriptor in responseDescriptors) {
        [self removeResponseDescriptor:responseDescriptor];
    }
}

@end
