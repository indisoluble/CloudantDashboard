//
//  ICDAuthorizationFactory.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 26/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import "ICDAuthorizationFactory.h"

#import "ICDAuthorizationKeychain.h"



@interface ICDAuthorizationFactory ()

@end



@implementation ICDAuthorizationFactory

#pragma mark - Public class methods
+ (id<ICDAuthorizationProtocol>)authorization
{
    return [[ICDAuthorizationKeychain alloc] init];
}

@end
