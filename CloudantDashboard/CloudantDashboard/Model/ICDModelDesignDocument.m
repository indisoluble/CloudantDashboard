//
//  ICDModelDesignDocument.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 21/01/2015.
//  Copyright (c) 2015 Enrique de la Torre. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file
//  except in compliance with the License. You may obtain a copy of the License at
//    http://www.apache.org/licenses/LICENSE-2.0
//  Unless required by applicable law or agreed to in writing, software distributed under the
//  License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
//  either express or implied. See the License for the specific language governing permissions
//  and limitations under the License.
//

#import "ICDModelDesignDocument.h"



#define ICDMODELDESIGNDOCUMENT_LANGUAGE_VALUE_JAVASCRIPT    @"javascript"



@interface ICDModelDesignDocument ()

@end



@implementation ICDModelDesignDocument

#pragma mark - Synthesize properties
- (void)setLanguage:(NSString *)language
{
    _language = (language ? language : @"");
}

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
        _language = @"";
        _views = [NSSet set];
    }
    
    return self;
}


#pragma mark - NSObject methods
- (NSString *)description
{
    return [NSString stringWithFormat:@"Design doc <%@, %@> Language <%@> Views <%@>",
            self.documentId, self.documentRev, self.language, self.views];
}


#pragma mark - Public methods
- (BOOL)isASecondaryIndex
{
    return [self.language isEqualToString:ICDMODELDESIGNDOCUMENT_LANGUAGE_VALUE_JAVASCRIPT];
}

@end
