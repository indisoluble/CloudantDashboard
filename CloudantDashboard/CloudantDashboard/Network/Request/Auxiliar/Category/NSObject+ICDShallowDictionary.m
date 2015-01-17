//
//  NSObject+ICDShallowDictionary.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 17/01/2015.
//  Copyright (c) 2015 Enrique de la Torre. All rights reserved.
//

#import <objc/runtime.h>
#import <objc/message.h>

#import "NSObject+ICDShallowDictionary.h"



#define NSOBJECTICDSHALLOWDICTIONARY_MSGSEND    ((id (*)(id, SEL))objc_msgSend)



@implementation NSObject (ICDShallowDictionary)

#pragma mark - Public methods
- (NSDictionary *)icdShallowDictionary
{
    unsigned int outCount = 0;
    objc_property_t *propertyList = class_copyPropertyList([self class], &outCount);
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:outCount];
    
    for (unsigned int index = 0; index < outCount; index++)
    {
        @autoreleasepool
        {
            NSString *propertyName = [NSString stringWithCString:property_getName(propertyList[index])
                                                        encoding:NSUTF8StringEncoding];
            id propertyValue = NSOBJECTICDSHALLOWDICTIONARY_MSGSEND(self, NSSelectorFromString(propertyName));
            
            if (propertyValue)
            {
                [dictionary setObject:propertyValue forKey:propertyName];
            }
        }
    }
    
    free(propertyList);
    
    return dictionary;
}

@end
