//
//  ICDRequestResponseValueError.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 24/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import "ICDRequestResponseValueError.h"



@interface ICDRequestResponseValueError ()

@end



@implementation ICDRequestResponseValueError

#pragma mark - NSObject methods
- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ (%@)", self.error, self.reason];
}

@end
