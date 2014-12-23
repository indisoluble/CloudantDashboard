//
//  ICDModelDocument.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 23/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import "ICDModelDocument.h"



@interface ICDModelDocument ()

@end



@implementation ICDModelDocument

#pragma mark - NSObject methods
- (NSString *)description
{
    return [NSString stringWithFormat:@"Document <%@, %@>", self.documentId, self.documentRev];
}

@end
