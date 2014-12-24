//
//  ICDDocumentViewController.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 23/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import "ICDDocumentViewController.h"

#import "ICDRequestDocument.h"

#import "ICDLog.h"



@interface ICDDocumentViewController () <ICDRequestDocumentDelegate>
{
    ICDRequestDocument *_requestDocument;
}

@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (strong, nonatomic, readonly) ICDRequestDocument *requestDocument;

@property (strong, nonatomic) ICDNetworkManager *networkManager;

@property (strong, nonatomic) NSString *databaseName;
@property (strong, nonatomic) NSString *documentId;

@property (strong, nonatomic) NSAttributedString *document;

@end



@implementation ICDDocumentViewController

#pragma mark - Synthesize properties
- (ICDRequestDocument *)requestDocument
{
    if (!_requestDocument && self.databaseName && self.documentId)
    {
        _requestDocument = [[ICDRequestDocument alloc] initWithDatabaseName:self.databaseName
                                                                 documentId:self.documentId];
        _requestDocument.delegate = self;
    }
    
    return _requestDocument;
}


#pragma mark - Memory management
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}


#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self presentDocument];
}


#pragma mark - ICDRequestDocumentDelegate methods
- (void)requestDocument:(id<ICDRequestProtocol>)request didGetDocument:(NSAttributedString *)document
{
    if (request != self.requestDocument)
    {
        ICDLogDebug(@"Received document from unexpected request. Ignore");
        
        return;
    }
    
    self.document = document;
    
    if ([self isViewLoaded])
    {
        [self presentDocument];
    }
}

- (void)requestDocument:(id<ICDRequestProtocol>)request didFailWithError:(NSError *)error
{
    if (request != self.requestDocument)
    {
        ICDLogDebug(@"Received error from unexpected request. Ignore");
        
        return;
    }
    
    ICDLogError(@"Error: %@", error);
}


#pragma mark - Public methods
- (void)useNetworkManager:(ICDNetworkManager *)networkManager
             databaseName:(NSString *)databaseName
               documentId:(NSString *)documentId
{
    self.networkManager = networkManager;
    self.databaseName = databaseName;
    self.documentId = documentId;
    
    [self releaseRequestDocument];
    
    [self executeRequestDocument];
}


#pragma mark - Private methods
- (void)releaseRequestDocument
{
    if (_requestDocument)
    {
        _requestDocument.delegate = nil;
        _requestDocument = nil;
    }
}

- (void)executeRequestDocument
{
    if (self.networkManager && self.requestDocument)
    {
        [self.networkManager executeRequest:self.requestDocument];
    }
}

- (void)presentDocument
{
    if (self.document)
    {
        self.textView.attributedText = self.document;
        
        self.document = nil;
    }
}

@end
