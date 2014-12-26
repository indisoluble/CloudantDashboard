//
//  ICDAuthorizationProtocol.h
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 21/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import <Foundation/Foundation.h>



@protocol ICDAuthorizationProtocol <NSObject>

- (BOOL)retrieveUsername:(NSString **)username
                password:(NSString **)password
                   error:(NSError **)error;

- (BOOL)saveUsername:(NSString *)username
            password:(NSString *)password
               error:(NSError **)error;

- (BOOL)removeUsernamePasswordError:(NSError **)error;

@end
