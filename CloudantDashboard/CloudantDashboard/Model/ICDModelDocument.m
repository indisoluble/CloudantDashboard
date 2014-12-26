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

#pragma mark - Synthesize properties
- (void)setDocumentId:(NSString *)documentId
{
    _documentId = (documentId ? documentId : @"");
}

- (void)setDocumentRev:(NSString *)documentRev
{
    _documentRev = (documentRev ? documentRev : @"");
}


#pragma mark - Init object
- (id)init
{
    self = [super init];
    if (self)
    {
        _documentId = @"";
        _documentRev = @"";
    }
    
    return self;
}


#pragma mark - NSObject methods
- (NSString *)description
{
    return [NSString stringWithFormat:@"Document <%@, %@>", self.documentId, self.documentRev];
}

- (BOOL)isEqual:(id)object
{
    BOOL result = NO;
    
    if ([object isKindOfClass:[ICDModelDocument class]])
    {
        ICDModelDocument *otherDocument = (ICDModelDocument *)object;
        
        return ([self.documentId isEqual:otherDocument.documentId] &&
                [self.documentRev isEqual:otherDocument.documentRev]);
    }
    
    return result;
}

// NOTE: 'hash' is a propertt in iOS 8.0
- (NSUInteger)hash
{
    return [[self.documentId stringByAppendingString:self.documentRev] hash];
}


#pragma mark - Public class methods
+ (instancetype)documentWithId:(NSString *)documentId rev:(NSString *)documentRev
{
    ICDModelDocument *document = [[ICDModelDocument alloc] init];
    document.documentId = documentId;
    document.documentRev = documentRev;
    
    return document;
}

@end
