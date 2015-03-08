//
//  ICDRequestAddRevisionNotification.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 31/12/2014.
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

#import "ICDRequestAddRevisionNotification.h"



NSString * const kICDRequestAddRevisionNotificationDidAddRevision = @"kICDRequestAddRevisionNotificationDidAddRevision";
NSString * const kICDRequestAddRevisionNotificationDidAddRevisionUserInfoKeyDatabaseName = @"kICDRequestAddRevisionNotificationDidAddRevisionUserInfoKeyDatabaseName";
NSString * const kICDRequestAddRevisionNotificationDidAddRevisionUserInfoKeyRevision = @"kICDRequestAddRevisionNotificationDidAddRevisionUserInfoKeyRevision";

NSString * const kICDRequestAddRevisionNotificationDidFail = @"kICDRequestAddRevisionNotificationDidFail";
NSString * const kICDRequestAddRevisionNotificationDidFailUserInfoKeyDatabaseName = @"kICDRequestAddRevisionNotificationDidFailUserInfoKeyDatabaseName";
NSString * const kICDRequestAddRevisionNotificationDidFailUserInfoKeyDocumentId = @"kICDRequestAddRevisionNotificationDidFailUserInfoKeyDocumentId";
NSString * const kICDRequestAddRevisionNotificationDidFailUserInfoKeyError = @"kICDRequestAddRevisionNotificationDidFailUserInfoKeyError";



@interface ICDRequestAddRevisionNotification ()

@property (strong, nonatomic) NSNotificationCenter *notificationCenter;

@end



@implementation ICDRequestAddRevisionNotification

#pragma mark - Init object
- (id)init
{
    return [self initWithNotificationCenter:nil];
}

- (id)initWithNotificationCenter:(NSNotificationCenter *)notificationCenterOrNil
{
    self = [super init];
    if (self)
    {
        _notificationCenter = (notificationCenterOrNil ? notificationCenterOrNil : [NSNotificationCenter defaultCenter]);
    }
    
    return self;
}


#pragma mark - Public methods
- (void)addDidAddRevisionNotificationObserver:(id)observer selector:(SEL)aSelector
{
    [self.notificationCenter addObserver:observer
                                selector:aSelector
                                    name:kICDRequestAddRevisionNotificationDidAddRevision
                                  object:nil];
}

- (void)removeDidAddRevisionNotificationObserver:(id)observer
{
    [self.notificationCenter removeObserver:observer
                                       name:kICDRequestAddRevisionNotificationDidAddRevision
                                     object:nil];
}

- (void)postDidAddRevisionNotificationWithDatabaseName:(NSString *)dbName revision:(ICDModelDocument *)revision
{
    [self.notificationCenter postNotificationName:kICDRequestAddRevisionNotificationDidAddRevision
                                           object:nil
                                         userInfo:@{kICDRequestAddRevisionNotificationDidAddRevisionUserInfoKeyDatabaseName: dbName,
                                                    kICDRequestAddRevisionNotificationDidAddRevisionUserInfoKeyRevision: revision}];
}

- (void)addDidFailNotificationObserver:(id)observer selector:(SEL)aSelector
{
    [self.notificationCenter addObserver:observer
                                selector:aSelector
                                    name:kICDRequestAddRevisionNotificationDidFail
                                  object:nil];
}

- (void)removeDidFailNotificationObserver:(id)observer
{
    [self.notificationCenter removeObserver:observer
                                       name:kICDRequestAddRevisionNotificationDidFail
                                     object:nil];
}

- (void)postDidFailNotificationWithDatabaseName:(NSString *)dbName documentId:(NSString *)documentId error:(NSError *)error
{
    [self.notificationCenter postNotificationName:kICDRequestAddRevisionNotificationDidFail
                                           object:nil
                                         userInfo:@{kICDRequestAddRevisionNotificationDidFailUserInfoKeyDatabaseName: dbName,
                                                    kICDRequestAddRevisionNotificationDidFailUserInfoKeyDocumentId: documentId,
                                                    kICDRequestAddRevisionNotificationDidFailUserInfoKeyError: error}];
}


#pragma mark - Public clas methods
+ (instancetype)sharedInstance
{
    static id sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

@end
