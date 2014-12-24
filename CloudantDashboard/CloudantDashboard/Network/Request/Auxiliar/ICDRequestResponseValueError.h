//
//  ICDRequestResponseValueError.h
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 24/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import <Foundation/Foundation.h>



#define ICDREQUESTRESPONSEVALUEERROR_PROPERTY_KEY_ERROR     @"error"
#define ICDREQUESTRESPONSEVALUEERROR_PROPERTY_KEY_REASON    @"reason"



@interface ICDRequestResponseValueError : NSObject

@property (strong, nonatomic) NSString *error;
@property (strong, nonatomic) NSString *reason;

@end
