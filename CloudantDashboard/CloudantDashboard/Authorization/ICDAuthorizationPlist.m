//
//  ICDAuthorizationPlist.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 21/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import "ICDAuthorizationPlist.h"

#import "ICDAuthorizationErrorBuilder.h"



#define ICDAUTHORIZATION_DEFAULTPLIST_FILENAME  @"cloudantAuthorization"
#define ICDAUTHORIZATION_DEFAULTPLIST_EXTENSION @"plist"



NSString * const kICDAuthorizationPlistKeyUsername = @"username";
NSString * const kICDAuthorizationPlistKeyPassword = @"password";



@interface ICDAuthorizationPlist ()

@property (strong, nonatomic) NSString *path;

@end



@implementation ICDAuthorizationPlist

#pragma mark - Init object
- (id)init
{
    NSString *path = [[NSBundle mainBundle] pathForResource:ICDAUTHORIZATION_DEFAULTPLIST_FILENAME
                                                     ofType:ICDAUTHORIZATION_DEFAULTPLIST_EXTENSION];
    
    return [self initWithPlistAtPath:path];
}

- (id)initWithPlistAtPath:(NSString *)path
{
    self = [super init];
    if (self)
    {
        _path = path;
    }
    
    return self;
}

#pragma mark - ICDAuthorizationProtocol methods
- (BOOL)resolveUsername:(NSString **)username
               password:(NSString **)password
                  error:(NSError **)error
{
    NSString *thisUsername = nil;
    NSString *thisPassword = nil;
    
    if (self.path)
    {
        NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:self.path];
        if (dictionary)
        {
            thisUsername = (NSString *)dictionary[kICDAuthorizationPlistKeyUsername];
            thisPassword = (NSString *)dictionary[kICDAuthorizationPlistKeyPassword];
        }
    }
    
    BOOL success = (thisUsername && thisPassword);
    if (success)
    {
        if (username)
        {
            *username = thisUsername;
        }
        
        if (password)
        {
            *password = thisPassword;
        }
    }
    else if (error)
    {
        *error = [ICDAuthorizationErrorBuilder errorAuthorizationDataNotFound];
    }
    
    return success;
}

@end
