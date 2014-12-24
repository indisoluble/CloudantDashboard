//
//  ICDModelDatabase.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 22/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
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


#pragma mark - Public class methods
+ (instancetype)databaseWithName:(NSString *)name
{
    ICDModelDatabase *db = [[ICDModelDatabase alloc] init];
    db.name = name;
    
    return db;
}

@end
