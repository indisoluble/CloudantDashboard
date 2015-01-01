//
//  ICDDocumentViewController.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 23/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import "ICDDocumentViewController.h"

#import "ICDRequestDocument.h"
#import "ICDRequestAddRevision.h"

#import "ICDJSONHighlightFactory.h"

#import "ICDLog.h"

#import "NSDictionary+CloudantSpecialKeys.h"



@interface ICDDocumentViewController () <ICDRequestDocumentDelegate, ICDRequestAddRevisionDelegate>

@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (strong, nonatomic) ICDNetworkManager *networkManager;

@property (strong, nonatomic) ICDRequestDocument *requestDocument;
@property (strong, nonatomic) ICDRequestAddRevision *requestAddRevision;

@property (strong, nonatomic) NSString *databaseName;
@property (strong, nonatomic) ICDModelDocument *currentDocument;
@property (strong, nonatomic) NSDictionary *currentDocumentData;
@property (strong, nonatomic) NSDictionary *nextDocumentData;

@property (strong, nonatomic) NSAttributedString *highlightedJSON;

@end



@implementation ICDDocumentViewController

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
    
    [self updateUIWithHighlightedJSON];
}


#pragma mark - ICDRequestDocumentDelegate methods
- (void)requestDocument:(id<ICDRequestProtocol>)request didGetDocument:(NSDictionary *)document
{
    if (request != self.requestDocument)
    {
        ICDLogDebug(@"Received document from unexpected request. Ignore");
        
        return;
    }
    
    [self releaseRequestDocument];
    
    self.currentDocumentData = document;
    
    self.title = self.currentDocument.documentId;
    
    [self updateUIWithCurrentDocumentData];
}

- (void)requestDocument:(id<ICDRequestProtocol>)request didFailWithError:(NSError *)error
{
    if (request != self.requestDocument)
    {
        ICDLogDebug(@"Received error from unexpected request. Ignore");
        
        return;
    }
    
    [self releaseRequestDocument];
    
    self.title = self.currentDocument.documentId;
    
    ICDLogError(@"Error: %@", error);
}


#pragma mark - ICDRequestAddRevisionDelegate methods
- (void)requestAddRevision:(id<ICDRequestProtocol>)request didAddRevision:(ICDModelDocument *)revision
{
    if (request != self.requestAddRevision)
    {
        ICDLogDebug(@"Received edited document from unexpected request. Ignore");
        
        return;
    }
    
    [self releaseRequestAddRevision];
    
    self.currentDocument = revision;
    self.currentDocumentData = self.nextDocumentData;
    self.nextDocumentData = nil;
    
    self.title = self.currentDocument.documentId;
    
    [self updateUIWithCurrentDocumentData];
}

- (void)requestAddRevision:(id<ICDRequestProtocol>)request didFailWithError:(NSError *)error
{
    if (request != self.requestAddRevision)
    {
        ICDLogDebug(@"Received error from unexpected request. Ignore");
        
        return;
    }
    
    [self releaseRequestAddRevision];
    
    self.nextDocumentData = nil;
    
    self.title = self.currentDocument.documentId;
    
    self.textView.editable = YES;
    
    ICDLogError(@"Error: %@", error);
}


#pragma mark - Public methods
- (void)useNetworkManager:(ICDNetworkManager *)networkManager
             databaseName:(NSString *)databaseName
                 document:(ICDModelDocument *)document
{
    if (document && document.documentId)
    {
        self.title = document.documentId;
    }
    
    self.highlightedJSON = nil;
    if ([self isViewLoaded])
    {
        [self clearUI];
    }
    
    self.networkManager = networkManager;
    
    self.databaseName = databaseName;
    self.currentDocument = document;
    self.currentDocumentData = nil;
    self.nextDocumentData = nil;
    
    [self releaseRequestDocument];
    [self releaseRequestAddRevision];
    
    [self executeRequestDocument];
}


#pragma mark - Private methods
- (void)clearUI
{
    [self removeBarButtomItem];
    
    self.textView.attributedText = [[NSAttributedString alloc] initWithString:@""];
}

- (void)updateUIWithCurrentDocumentData
{
    self.highlightedJSON = [[ICDJSONHighlightFactory jsonHighlight] highlightDictionary:self.currentDocumentData];
    if ([self isViewLoaded])
    {
        [self updateUIWithHighlightedJSON];
    }
}

- (void)updateUIWithHighlightedJSON
{
    if (self.highlightedJSON)
    {
        [self addEditBarButtonItem];
        
        self.textView.attributedText = self.highlightedJSON;
        
        self.highlightedJSON = nil;
    }
}

- (void)removeBarButtomItem
{
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)addEditBarButtonItem
{
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                          target:self
                                                                          action:@selector(prepareTextViewForEditingJSON)];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)prepareTextViewForEditingJSON
{
    [self addSaveBarButtonItem];
    
    NSMutableDictionary *dictionary = [self.currentDocumentData dictionaryWithoutCloudantSpecialKeys];
    self.textView.attributedText = [[ICDJSONHighlightFactory jsonHighlight] highlightDictionary:dictionary];
    
    self.textView.editable = YES;
}

- (void)addSaveBarButtonItem
{
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                          target:self
                                                                          action:@selector(checkJSONBeforeExecutingRequestAddRev)];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)checkJSONBeforeExecutingRequestAddRev
{
    NSString *text = self.textView.text;
    NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *error = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (!jsonObject)
    {
        [self showAlertViewWithTitle:NSLocalizedString(@"Error", @"Error")
                             message:[error localizedDescription]];
        
        return;
    }
    
    if (![jsonObject isKindOfClass:[NSDictionary class]])
    {
        [self showAlertViewWithTitle:NSLocalizedString(@"Error", @"Error")
                             message:NSLocalizedString(@"Document is not a dictionary", @"Document is not a dictionary")];
        
        return;
    }
    
    self.textView.editable = NO;
    self.textView.selectable = NO;
    
    self.nextDocumentData = (NSDictionary *)jsonObject;
    
    [self executeRequestAddRevision];
}

- (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"Continue", @"Continue")
                                              otherButtonTitles:nil];
    [alertView show];
}

- (void)executeRequestDocument
{
    if (!self.networkManager)
    {
        ICDLogTrace(@"No network manager. Abort");
        
        return;
    }
    
    NSString *documentId = (self.currentDocument ? self.currentDocument.documentId : nil );
    self.requestDocument = [[ICDRequestDocument alloc] initWithDatabaseName:self.databaseName documentId:documentId];
    if (!self.requestDocument)
    {
        ICDLogWarning(@"Request not created with dbName <%@> and docId <%@>", self.databaseName, documentId);
        
        return;
    }
    
    self.requestDocument.delegate = self;
    
    if ([self.networkManager asyncExecuteRequest:self.requestDocument])
    {
        self.title = NSLocalizedString(@"Downloading ...", @"Downloading ..");
    }
    else
    {
        [self releaseRequestDocument];
    }
}

- (void)releaseRequestDocument
{
    if (self.requestDocument)
    {
        self.requestDocument.delegate = nil;
        self.requestDocument = nil;
    }
}

- (void)executeRequestAddRevision
{
    if (!self.networkManager)
    {
        ICDLogTrace(@"No network manager. Abort");
        
        return;
    }
    
    NSString *documentId = (self.currentDocument ? self.currentDocument.documentId : nil );
    NSString *documentRev = (self.currentDocument ? self.currentDocument.documentRev : nil);
    self.requestAddRevision = [[ICDRequestAddRevision alloc] initWithDatabaseName:self.databaseName
                                                                       documentId:documentId
                                                                      documentRev:documentRev
                                                                     documentData:self.nextDocumentData];
    if (!self.requestAddRevision)
    {
        ICDLogWarning(@"Request not created with dbName <%@>, document %@ and data <%@>",
                      self.databaseName, self.currentDocument, self.nextDocumentData);
        
        return;
    }
    
    self.requestAddRevision.delegate = self;
    
    if ([self.networkManager asyncExecuteRequest:self.requestAddRevision])
    {
        self.title = NSLocalizedString(@"Saving ...", @"Saving ...");
    }
    else
    {
        [self releaseRequestAddRevision];
    }
}

- (void)releaseRequestAddRevision
{
    if (self.requestAddRevision)
    {
        self.requestAddRevision.delegate = nil;
        self.requestAddRevision = nil;
    }
}

@end
