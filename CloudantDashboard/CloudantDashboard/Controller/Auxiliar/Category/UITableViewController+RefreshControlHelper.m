//
//  UITableViewController+RefreshControlHelper.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 06/01/2015.
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

#import "UITableViewController+RefreshControlHelper.h"

#import "ICDLog.h"



#define UITABLEVIEWCONTROLLER_REFRESHCONTROLHELPER_ANIMATIONDURATION    0.3f



@implementation UITableViewController (RefreshControlHelper)

#pragma mark - Public methods
- (void)forceShowRefreshControlAnimation
{
    if (!self.refreshControl)
    {
        ICDLogWarning(@"Refresh Control not initialised");
        
        return;
    }
    
    [self.refreshControl beginRefreshing];
    
    if (self.tableView.contentOffset.y == 0)
    {
        __weak UITableViewController *weakSelf = self;
        void (^animationBlock)(void) = ^(void)
        {
            __strong UITableViewController *strongSelf = weakSelf;
            if (strongSelf)
            {
                strongSelf.tableView.contentOffset = CGPointMake(0, -strongSelf.refreshControl.frame.size.height);
            }
        };
        
        [UIView animateWithDuration:UITABLEVIEWCONTROLLER_REFRESHCONTROLHELPER_ANIMATIONDURATION
                              delay:0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:animationBlock
                         completion:nil];
        
    }
}

@end
