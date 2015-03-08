//
//  ICDLog.h
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 21/12/2014.
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

#ifndef CloudantDashboard_ICDLog_h
#define CloudantDashboard_ICDLog_h

#import <RestKit/RestKit.h>



#define ICDLogLevelOff      RKLogLevelOff
#define ICDLogLevelCritical RKLogLevelCritical
#define ICDLogLevelError    RKLogLevelError
#define ICDLogLevelWarning  RKLogLevelWarning
#define ICDLogLevelInfo     RKLogLevelInfo
#define ICDLogLevelDebug    RKLogLevelDebug
#define ICDLogLevelTrace    RKLogLevelTrace

#define ICDLogCritical(...) RKLogCritical(__VA_ARGS__)
#define ICDLogError(...)    RKLogError(__VA_ARGS__)
#define ICDLogWarning(...)  RKLogWarning(__VA_ARGS__)
#define ICDLogInfo(...)     RKLogInfo(__VA_ARGS__)
#define ICDLogDebug(...)    RKLogDebug(__VA_ARGS__)
#define ICDLogTrace(...)    RKLogTrace(__VA_ARGS__)

#define ICDLogConfigureLevel(level) RKLogConfigureByName("App", level)

#endif
