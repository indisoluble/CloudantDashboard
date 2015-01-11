//
//  ICDJSONHighlight.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 28/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import "ICDJSONHighlight.h"

#import <JSONSyntaxHighlight/JSONSyntaxHighlight.h>



@interface ICDJSONHighlight ()

@end



@implementation ICDJSONHighlight

#pragma mark - ICDJSONHighlightProtocol methods
- (NSAttributedString *)highlightDictionary:(NSDictionary *)dictionary
{
    JSONSyntaxHighlight *jsh = [[JSONSyntaxHighlight alloc] initWithJSON:dictionary];
    
    return [jsh highlightJSON];
}

@end
