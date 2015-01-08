//
//  ICDControllerOneDocumentVC.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 23/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//

#import "ICDControllerOneDocumentVC.h"

#import "ICDControllerOneDocumentData.h"

#import "ICDJSONHighlightFactory.h"

#import "ICDLog.h"

#import "NSDictionary+CloudantSpecialKeys.h"



@interface ICDControllerOneDocumentVC () <ICDControllerOneDocumentDataDelegate>

@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (strong, nonatomic, readonly) ICDControllerOneDocumentData *data;

@property (strong, nonatomic) NSAttributedString *highlightedJSON;

@end



@implementation ICDControllerOneDocumentVC

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


#pragma mark - ICDControllerOneDocumentDataDelegate methods
- (void)icdControllerOneDocumentData:(ICDControllerOneDocumentData *)data
             didGetFullDocWithResult:(BOOL)success
{
    self.title = self.data.documentOrNil.documentId;
    
    if (success)
    {
        [self updateUIWithFullDocument];
    }
}

- (void)icdControllerOneDocumentData:(ICDControllerOneDocumentData *)data
              didUpdateDocWithResult:(BOOL)success
{
    self.title = self.data.documentOrNil.documentId;
    
    if (success)
    {
        [self updateUIWithFullDocument];
    }
    else
    {
        self.textView.editable = YES;
    }
}


#pragma mark - Public methods
- (void)useNetworkManager:(id<ICDNetworkManagerProtocol>)networkManager
             databaseName:(NSString *)databaseName
                 document:(ICDModelDocument *)document
{
    self.highlightedJSON = nil;
    if ([self isViewLoaded])
    {
        [self clearUI];
    }
    
    [self recreateDataWithNetworkManager:networkManager databaseName:databaseName document:document];
    
    if ([self.data asyncGetFullDocument])
    {
        self.title = NSLocalizedString(@"Downloading ...", @"Downloading ..");
    }
    else if (self.data.documentOrNil && self.data.documentOrNil.documentId)
    {
        self.title = self.data.documentOrNil.documentId;
    }
}


#pragma mark - Private methods
- (void)clearUI
{
    [self removeBarButtomItem];
    
    self.textView.text = @"";
    self.textView.editable = NO;
    self.textView.selectable = NO;
}

- (void)updateUIWithFullDocument
{
    self.highlightedJSON = [[ICDJSONHighlightFactory jsonHighlight] highlightDictionary:self.data.fullDocument];
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
    
    NSMutableDictionary *dictionary = [self.data.fullDocument dictionaryWithoutCloudantSpecialKeys];
    self.textView.attributedText = [[ICDJSONHighlightFactory jsonHighlight] highlightDictionary:dictionary];
    
    self.textView.editable = YES;
}

- (void)addSaveBarButtonItem
{
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                          target:self
                                                                          action:@selector(checkJSONBeforeUpdatingDocument)];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)checkJSONBeforeUpdatingDocument
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
    
    if ([self.data asyncUpdateDocumentWithData:jsonObject])
    {
        self.title = NSLocalizedString(@"Saving ...", @"Saving ...");
    }
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

- (void)recreateDataWithNetworkManager:(id<ICDNetworkManagerProtocol>)networkManager
                          databaseName:(NSString *)databaseName
                              document:(ICDModelDocument *)document
{
    [self releaseData];
    
    _data = [[ICDControllerOneDocumentData alloc] initWithNetworkManager:networkManager
                                                            databaseName:databaseName
                                                                document:document];
    _data.delegate = self;
}

- (void)releaseData
{
    if (_data)
    {
        _data.delegate = nil;
        _data = nil;
    }
}

@end
