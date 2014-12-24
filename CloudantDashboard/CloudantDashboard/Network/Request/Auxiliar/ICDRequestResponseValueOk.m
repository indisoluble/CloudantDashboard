//
//  ICDRequestResponseValueOk.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 24/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import "ICDRequestResponseValueOk.h"



@interface ICDRequestResponseValueOk ()

@end



@implementation ICDRequestResponseValueOk

#pragma mark - NSObject methods
- (NSString *)description
{
    return [NSString stringWithFormat:@"%@: %@", ICDREQUESTRESPONSEVALUE_PROPERTY_KEY_OK, self.ok];
}

@end
