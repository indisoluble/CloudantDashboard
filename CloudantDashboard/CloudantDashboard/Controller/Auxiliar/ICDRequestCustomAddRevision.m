//
//  ICDRequestCustomAddRevision.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 08/01/2015.
//  Copyright (c) 2015 Enrique de la Torre. All rights reserved.
//

#import "ICDRequestCustomAddRevision.h"



@interface ICDRequestCustomAddRevision ()

@end



@implementation ICDRequestCustomAddRevision

#pragma mark - Init object
- (id)initWithDatabaseName:(NSString *)dbName
                documentId:(NSString *)docId
               documentRev:(NSString *)docRev
              documentData:(NSDictionary *)docData
              notification:(ICDRequestAddRevisionNotification *)notificationOrNil
{
    self = [super initWithDatabaseName:dbName documentId:docId documentRev:docRev documentData:docData notification:notificationOrNil];
    if (self)
    {
        _docData = docData;
    }
    
    return self;
}

@end
