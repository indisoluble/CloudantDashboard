//
//  ICDModelDocument.h
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 23/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import <Foundation/Foundation.h>



#define ICDMODELDOCUMENT_PROPERTY_KEY_ID    @"documentId"
#define ICDMODELDOCUMENT_PROPERTY_KEY_REV   @"documentRev"



extern NSString * const kICDModelDocumentDesignDocIdPrefix;



@interface ICDModelDocument : NSObject

@property (strong, nonatomic) NSString *documentId;
@property (strong, nonatomic) NSString *documentRev;

- (BOOL)isDesignDoc;

- (NSComparisonResult)compare:(ICDModelDocument *)otherDocument;

+ (instancetype)documentWithId:(NSString *)documentId rev:(NSString *)documentRev;

@end
