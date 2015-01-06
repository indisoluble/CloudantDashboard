//
//  NSIndexPath+IndexSetHelper.h
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 06/01/2015.
//  Copyright (c) 2015 Enrique de la Torre. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface NSIndexPath (IndexSetHelper)

+ (NSArray *)indexPathsForRows:(NSIndexSet *)rows inSection:(NSInteger)section;

@end
