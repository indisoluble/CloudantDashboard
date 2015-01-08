//
//  ICDRequestCustomAddRevision.h
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 08/01/2015.
//  Copyright (c) 2015 Enrique de la Torre. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ICDRequestAddRevision.h"



@interface ICDRequestCustomAddRevision : ICDRequestAddRevision

@property (strong, nonatomic, readonly) NSDictionary *docData;

@end
