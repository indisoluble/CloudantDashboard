//
//  ICDModelDesignDocumentView.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 21/01/2015.
//  Copyright (c) 2015 Enrique de la Torre. All rights reserved.
//

#import "ICDModelDesignDocumentView.h"



@interface ICDModelDesignDocumentView ()

@end



@implementation ICDModelDesignDocumentView

#pragma mark - Synthesize properties
- (void)setViewname:(NSString *)viewname
{
    _viewname = (viewname ? viewname : @"");
}

- (void)setMapFunction:(NSString *)mapFunction
{
    _mapFunction = (mapFunction ? mapFunction : @"");
}


#pragma mark - Init object
- (id)init
{
    self = [super init];
    if (self)
    {
        _viewname = @"";
        _mapFunction = @"";
    }
    
    return self;
}


#pragma mark - NSObject methods
- (NSString *)description
{
    return [NSString stringWithFormat:@"Name <%@> Map\n<%@>", self.viewname, self.mapFunction];
}

@end
