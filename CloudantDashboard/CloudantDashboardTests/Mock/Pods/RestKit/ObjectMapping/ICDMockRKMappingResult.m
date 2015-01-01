//
//  ICDMockRKMappingResult.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 31/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import "ICDMockRKMappingResult.h"



@interface ICDMockRKMappingResult ()

@end



@implementation ICDMockRKMappingResult

#pragma mark - Public methods
- (id)firstObject
{
    return self.firstObjectResult;
}

- (NSArray *)array
{
    return self.arrayResult;
}

@end
