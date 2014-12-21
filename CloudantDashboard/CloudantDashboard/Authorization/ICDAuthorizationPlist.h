//
//  ICDAuthorizationPlist.h
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 21/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ICDAuthorizationProtocol.h"



@interface ICDAuthorizationPlist : NSObject <ICDAuthorizationProtocol>

- (id)initWithPlistAtPath:(NSString *)path;

@end
