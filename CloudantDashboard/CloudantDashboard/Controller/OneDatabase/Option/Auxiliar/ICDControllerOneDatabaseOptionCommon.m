//
//  ICDControllerOneDatabaseOptionCommon.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 16/01/2015.
//  Copyright (c) 2015 Enrique de la Torre. All rights reserved.
//

#import "ICDControllerOneDatabaseOptionCommon.h"



NSString * const kICDControllerOneDatabaseOptionCellID = @"databaseOptionCell";



@interface ICDControllerOneDatabaseOptionCommon ()

@end



@implementation ICDControllerOneDatabaseOptionCommon

#pragma mark - Private class methods
+ (UITableViewCell *)dequeueCommonCellFromTableView:(UITableView *)tableView
                                        atIndexPath:(NSIndexPath *)indexPath
{
    return [tableView dequeueReusableCellWithIdentifier:kICDControllerOneDatabaseOptionCellID
                                           forIndexPath:indexPath];
}

@end
