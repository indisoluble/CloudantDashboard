//
//  ICDModelDesignDocument.h
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 21/01/2015.
//  Copyright (c) 2015 Enrique de la Torre. All rights reserved.
//

#import "ICDModelDocument.h"



#define ICDMODELDESIGNDOCUMENT_PROPERTY_KEY_LANGUAGE    @"language"
#define ICDMODELDESIGNDOCUMENT_PROPERTY_KEY_VIEWS       @"views"



@interface ICDModelDesignDocument : ICDModelDocument

@property (strong, nonatomic) NSString *language;
@property (strong, nonatomic) NSSet *views;

- (BOOL)isASecondaryIndex;

@end
