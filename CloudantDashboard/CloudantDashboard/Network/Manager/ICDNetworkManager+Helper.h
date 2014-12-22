//
//  ICDNetworkManager+Helper.h
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 22/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import "ICDNetworkManager.h"



@interface ICDNetworkManager (Helper)

+ (instancetype)networkManagerWithUsername:(NSString *)username
                                  password:(NSString *)password;

@end
