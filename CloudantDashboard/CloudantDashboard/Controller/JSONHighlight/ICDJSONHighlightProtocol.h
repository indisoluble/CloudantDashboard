//
//  ICDJSONHighlightProtocol.h
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 28/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import <Foundation/Foundation.h>



@protocol ICDJSONHighlightProtocol <NSObject>

- (NSAttributedString *)highlightDictionary:(NSDictionary *)dictionary;

@end
