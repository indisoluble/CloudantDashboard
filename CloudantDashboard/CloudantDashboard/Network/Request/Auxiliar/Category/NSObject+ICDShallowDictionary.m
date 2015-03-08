//
//  NSObject+ICDShallowDictionary.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 17/01/2015.
//  Copyright (c) 2015 Enrique de la Torre. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file
//  except in compliance with the License. You may obtain a copy of the License at
//    http://www.apache.org/licenses/LICENSE-2.0
//  Unless required by applicable law or agreed to in writing, software distributed under the
//  License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
//  either express or implied. See the License for the specific language governing permissions
//  and limitations under the License.
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
