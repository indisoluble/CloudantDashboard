//
//  UITableViewController+RefreshControlHelper.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 06/01/2015.
//  Copyright (c) 2015 Enrique de la Torre. All rights reserved.
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
