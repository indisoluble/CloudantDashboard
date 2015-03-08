//
//  ICDModelDocument.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 23/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file
//  except in compliance with the License. You may obtain a copy of the License at
//    http://www.apache.org/licenses/LICENSE-2.0
//  Unless required by applicable law or agreed to in writing, software distributed under the
//  License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
//  either express or implied. See the License for the specific language governing permissions
//  and limitations under the License.
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


#pragma mark - Public methods
- (NSComparisonResult)compare:(ICDModelDocument *)otherDocument
{
    NSComparisonResult result = [self.documentId compare:otherDocument.documentId];
    if (result == NSOrderedSame)
    {
        result = [self.documentRev compare:otherDocument.documentRev];
    }
    
    return result;
}


#pragma mark - Public class methods
+ (instancetype)documentWithId:(NSString *)documentId rev:(NSString *)documentRev
{
    ICDModelDocument *document = (ICDModelDocument *)[[[self class] alloc] init];
    document.documentId = documentId;
    document.documentRev = documentRev;
    
    return document;
}

@end
