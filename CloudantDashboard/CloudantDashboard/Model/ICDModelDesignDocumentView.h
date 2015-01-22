//
//  ICDModelDesignDocumentView.h
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 21/01/2015.
//  Copyright (c) 2015 Enrique de la Torre. All rights reserved.
//

#import <Foundation/Foundation.h>



#define ICDMODELDESIGNDOCUMENTVIEW_PROPERTY_KEY_VIEWNAME    @"viewname"
#define ICDMODELDESIGNDOCUMENTVIEW_PROPERTY_KEY_MAPFUNCTION @"mapFunction"



@interface ICDModelDesignDocumentView : NSObject

@property (strong, nonatomic) NSString *viewname;
@property (strong, nonatomic) NSString *mapFunction;

@end
