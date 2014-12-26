//
//  ICDAuthorizationKeychain.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 26/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import <UICKeyChainStore/UICKeyChainStore.h>

#import "ICDAuthorizationKeychain.h"

#import "ICDAuthorizationErrorBuilder.h"

#import "ICDLog.h"



NSString * const kICDAuthorizationKeychainKeyUsername = @"username";
NSString * const kICDAuthorizationKeychainKeyPassword = @"password";



@interface ICDAuthorizationKeychain ()

@end



@implementation ICDAuthorizationKeychain

#pragma mark - ICDAuthorizationProtocol methods
- (BOOL)resolveUsername:(NSString **)username
               password:(NSString **)password
                  error:(NSError **)error
{
    NSError *thisError = nil;
    
    NSString *thisUsername = [UICKeyChainStore stringForKey:kICDAuthorizationKeychainKeyUsername error:&thisError];
    if (!thisUsername)
    {
        ICDLogDebug(@"Username not found: %@", thisError);
    }
    
    NSString *thisPassword = [UICKeyChainStore stringForKey:kICDAuthorizationKeychainKeyPassword error:&thisError];
    if (!thisPassword)
    {
        ICDLogDebug(@"Password not found: %@", thisError);
    }
    
    if (!thisUsername || !thisPassword)
    {
        if (error)
        {
            *error = [ICDAuthorizationErrorBuilder errorAuthorizationDataNotFound];
        }
        
        return NO;
    }
    
    if (username)
    {
        *username = thisUsername;
    }
    
    if (password)
    {
        *password = thisPassword;
    }
    
    return YES;
}

- (BOOL)saveUsername:(NSString *)username
            password:(NSString *)password
               error:(NSError **)error
{
    if (!username || !password || ([username length] == 0) || ([password length] == 0))
    {
        if (error)
        {
            *error = [ICDAuthorizationErrorBuilder errorAuthorizationDataNotValid];
        }
        
        return NO;
    }
    
    NSError *usernameError = nil;
    NSError *passwordError = nil;
    BOOL success = ([UICKeyChainStore setString:username forKey:kICDAuthorizationKeychainKeyUsername error:&usernameError] &&
                    [UICKeyChainStore setString:password forKey:kICDAuthorizationKeychainKeyPassword error:&passwordError]);
    if (!success)
    {
        ICDLogError(@"Auth data not saved. Username: %@. Password: %@", usernameError, passwordError);
        
        if (![UICKeyChainStore removeItemForKey:kICDAuthorizationKeychainKeyUsername error:&usernameError])
        {
            ICDLogError(@"Username not deleted: %@", usernameError);
        }
        
        if (![UICKeyChainStore removeItemForKey:kICDAuthorizationKeychainKeyPassword error:&passwordError])
        {
            ICDLogError(@"Password not deleted: %@", passwordError);
        }
        
        if (error)
        {
            *error = [ICDAuthorizationErrorBuilder errorAuthorizationDataNotSaved];
        }
    }
    
    return success;
}

@end
