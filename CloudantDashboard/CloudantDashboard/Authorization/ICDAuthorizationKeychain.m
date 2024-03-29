//
//  ICDAuthorizationKeychain.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 26/12/2014.
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
- (BOOL)retrieveUsername:(NSString **)username
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
    NSString *trimmedUsername = (username ?
                                 [username stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] :
                                 nil);
    
    if (!trimmedUsername || !password || ([trimmedUsername length] == 0) || ([password length] == 0))
    {
        if (error)
        {
            *error = [ICDAuthorizationErrorBuilder errorAuthorizationDataNotValid];
        }
        
        return NO;
    }
    
    NSError *usernameError = nil;
    NSError *passwordError = nil;
    BOOL success = ([UICKeyChainStore setString:trimmedUsername forKey:kICDAuthorizationKeychainKeyUsername error:&usernameError] &&
                    [UICKeyChainStore setString:password forKey:kICDAuthorizationKeychainKeyPassword error:&passwordError]);
    if (!success)
    {
        ICDLogError(@"Auth data not saved. Username: %@. Password: %@", usernameError, passwordError);
        
        [self removeUsernamePasswordError:nil];
        
        if (error)
        {
            *error = [ICDAuthorizationErrorBuilder errorAuthorizationDataNotSaved];
        }
    }
    
    return success;
}

- (BOOL)removeUsernamePasswordError:(NSError **)error
{
    BOOL success = YES;
    
    NSError *thisError = nil;
    if (![UICKeyChainStore removeItemForKey:kICDAuthorizationKeychainKeyUsername error:&thisError])
    {
        ICDLogError(@"Username not deleted: %@", thisError);
        
        success = NO;
    }
    
    if (![UICKeyChainStore removeItemForKey:kICDAuthorizationKeychainKeyPassword error:&thisError])
    {
        ICDLogError(@"Password not deleted: %@", thisError);
        
        success = NO;
    }
    
    if (!success && error)
    {
        *error = [ICDAuthorizationErrorBuilder errorAuthorizationDataNotDeleted];
    }
    
    return success;
}

@end
