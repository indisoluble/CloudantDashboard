//
//  ICDJSONHighlightFactory.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 28/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import "ICDJSONHighlightFactory.h"

#import "ICDJSONHighlight.h"



@interface ICDJSONHighlightFactory ()

@end



@implementation ICDJSONHighlightFactory

#pragma mark - Public class methods
+ (id<ICDJSONHighlightProtocol>)jsonHighlight
{
    return [[ICDJSONHighlight alloc] init];
}

@end
