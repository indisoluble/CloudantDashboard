//
//  ICDModelDesignDocument.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 21/01/2015.
//  Copyright (c) 2015 Enrique de la Torre. All rights reserved.
//

#import "ICDModelDesignDocument.h"



@interface ICDModelDesignDocument ()

@end



@implementation ICDModelDesignDocument

#pragma mark - Synthesize properties
- (void)setViews:(NSSet *)views
{
    _views = (views ? views : [NSSet set]);
}


#pragma mark - Init object
- (id)init
{
    self = [super init];
    if (self)
    {
        _views = [NSSet set];
    }
    
    return self;
}


#pragma mark - NSObject methods
- (NSString *)description
{
    return [NSString stringWithFormat:@"Design doc <%@, %@> Views <%@>",
            self.documentId, self.documentRev, self.views];
}

@end
