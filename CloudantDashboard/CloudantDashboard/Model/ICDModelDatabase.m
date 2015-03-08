//
//  ICDModelDatabase.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 22/12/2014.
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

#import "ICDModelDatabase.h"



@interface ICDModelDatabase ()

@end



@implementation ICDModelDatabase

#pragma mark - Synthesize properties
- (void)setName:(NSString *)name
{
    _name = (name ? name : @"");
}


#pragma mark - Init object
- (id)init
{
    self = [super init];
    if (self)
    {
        _name = @"";
    }
    
    return self;
}


#pragma mark - NSObject methods
- (NSString *)description
{
    return [NSString stringWithFormat:@"Database <%@>", self.name];
}

- (BOOL)isEqual:(id)object
{
    BOOL result = NO;
    
    if ([object isKindOfClass:[ICDModelDatabase class]])
    {
        ICDModelDatabase *otherDatabase = (ICDModelDatabase *)object;
        
        result = [self.name isEqual:otherDatabase.name];
    }
    
    return result;
}

// NOTE: 'hash' is a propertt in iOS 8.0
- (NSUInteger)hash
{
    return self.name.hash;
}


#pragma mark - Public methods
- (NSComparisonResult)compare:(ICDModelDatabase *)otherDatabase
{
    return [self.name compare:otherDatabase.name];
}


#pragma mark - Public class methods
+ (instancetype)databaseWithName:(NSString *)name
{
    ICDModelDatabase *db = [[ICDModelDatabase alloc] init];
    db.name = name;
    
    return db;
}

@end
