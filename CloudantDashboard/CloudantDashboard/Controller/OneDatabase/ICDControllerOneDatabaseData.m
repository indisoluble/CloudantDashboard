//
//  ICDControllerOneDatabaseData.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 18/01/2015.
//  Copyright (c) 2015 Enrique de la Torre. All rights reserved.
//

#import "ICDControllerOneDatabaseData.h"

#import "ICDControllerOneDatabaseOptionAllDocs.h"
#import "ICDControllerOneDatabaseOptionAllDesignDocs.h"



@interface ICDControllerOneDatabaseData ()

@property (strong, nonatomic, readonly) NSArray *options;

@end



@implementation ICDControllerOneDatabaseData

#pragma mark - Init object
- (id)init
{
    return [self initWithDatabaseName:nil networkManager:nil];
}

- (id)initWithDatabaseName:(NSString *)databaseNameOrNil
            networkManager:(id<ICDNetworkManagerProtocol>)networkManagerOrNil
{
    self = [super init];
    if (self)
    {
        if (databaseNameOrNil && networkManagerOrNil)
        {
            _options = @[[ICDControllerOneDatabaseOptionAllDocs optionWithDatabaseName:databaseNameOrNil
                                                                        networkManager:networkManagerOrNil],
                         [ICDControllerOneDatabaseOptionAllDesignDocs optionWithDatabaseName:databaseNameOrNil
                                                                              networkManager:networkManagerOrNil]];
        }
        else
        {
            _options = @[];
        }
    }
    
    return self;
}


#pragma mark - Public methods
- (NSInteger)numberOfOptions
{
    return [self.options count];
}

- (id<ICDControllerOneDatabaseOptionProtocol>)optionAtIndex:(NSUInteger)index
{
    return (id<ICDControllerOneDatabaseOptionProtocol>)self.options[index];
}

@end
