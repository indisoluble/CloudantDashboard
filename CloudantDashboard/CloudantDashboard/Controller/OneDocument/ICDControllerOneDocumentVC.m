//
//  ICDControllerOneDocumentVC.m
//  CloudantDashboard
//
//  Created by Enrique de la Torre (dev) on 23/12/2014.
//  Copyright (c) 2014 Enrique de la Torre. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file
//  except in compliance with the License. You may obtain a copy of the License at
//    http://www.apache.org/licenses/LICENSE-2.0
//  Unless required by applicable law or agreed to in writing, software distributed under the
//  License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
//  either express or implied. See the License for the specific language governing permissions
//  and limitations under the License.
//

#import <UIAlertView-Blocks/UIAlertView+Blocks.h>

#import "ICDControllerOneDocumentVC.h"

#import "ICDControllerOneDocumentData.h"

#import "ICDJSONHighlightFactory.h"

#import "ICDLog.h"

#import "NSString+CloudantDesignDocId.h"
#import "NSDictionary+CloudantSpecialKeys.h"



@interface ICDControllerOneDocumentVC () <ICDControllerOneDocumentDataDelegate>

@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (strong, nonatomic, readonly) ICDControllerOneDocumentData *data;

@property (assign, nonatomic) BOOL allowCopy;
@property (strong, nonatomic) NSAttributedString *highlightedJSON;

@end



@implementation ICDControllerOneDocumentVC

#pragma mark - Init object
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        _data = [[ICDControllerOneDocumentData alloc] init];
        _data.delegate = self;
        
        _allowCopy = NO;
        _highlightedJSON = nil;
    }
    
    return self;
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
    
    [self updateUIWithHighlightedJSON];
}


#pragma mark - ICDControllerOneDocumentDataDelegate methods
- (void)icdControllerOneDocumentData:(ICDControllerOneDocumentData *)data
             didGetFullDocWithResult:(BOOL)success
{
    self.title = self.data.documentIdOrNil;
    
    if (success)
    {
        [self updateUIWithFullDocument];
    }
}

- (void)icdControllerOneDocumentData:(ICDControllerOneDocumentData *)data
              didUpdateDocWithResult:(BOOL)success
{
    self.title = self.data.documentIdOrNil;
    
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
               documentId:(NSString *)documentId
            allowCopyData:(BOOL)allowCopy
{
    self.allowCopy = allowCopy;
    
    self.highlightedJSON = nil;
    if ([self isViewLoaded])
    {
        [self clearUI];
    }
    
    [self recreateDataWithNetworkManager:networkManager databaseName:databaseName documentId:documentId];
    
    if ([self.data asyncGetFullDocument])
    {
        self.title = NSLocalizedString(@"Downloading ...", @"Downloading ..");
    }
    else if (self.data.documentIdOrNil)
    {
        self.title = self.data.documentIdOrNil;
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
        [self addRightBarButtonItems];
        
        self.textView.attributedText = self.highlightedJSON;
        
        self.highlightedJSON = nil;
    }
}

- (void)removeBarButtomItem
{
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)addRightBarButtonItems
{
    self.navigationItem.rightBarButtonItems = (self.allowCopy ?
                                               @[[self editBarButtonItem], [self copyBarButtonItem]] :
                                               @[[self editBarButtonItem]]);
}

- (UIBarButtonItem *)editBarButtonItem
{
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                          target:self
                                                                          action:@selector(prepareTextViewForEditingJSON)];
    
    return item;
}

- (UIBarButtonItem *)copyBarButtonItem
{
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Copy", @"Copy")
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(askHowManyTimesDocumentHasToBeCopied)];
    
    return item;
}

- (void)prepareTextViewForEditingJSON
{
    [self replaceRightBarButtonsWithSaveBarButtonItem];
    
    NSMutableDictionary *dictionary = [self.data.fullDocument dictionaryWithoutCloudantSpecialKeys];
    self.textView.attributedText = [[ICDJSONHighlightFactory jsonHighlight] highlightDictionary:dictionary];
    
    self.textView.editable = YES;
}

- (void)askHowManyTimesDocumentHasToBeCopied
{
    __block UIAlertView *alertView = nil;
    __weak ICDControllerOneDocumentVC *weakSelf = self;
    
    void (^continueAction)(void) = ^(void)
    {
        __strong ICDControllerOneDocumentVC *strongSelf = weakSelf;
        if (!strongSelf)
        {
            return;
        }
        
        UITextField *textField = [alertView textFieldAtIndex:0];
        NSInteger numberOfCopies = [textField.text integerValue];
        if (numberOfCopies <= 0)
        {
            ICDLogTrace(@"Provided negative value: %li", (long)numberOfCopies);
            
            return;
        }
        
        if (strongSelf.delegate)
        {
            [strongSelf.delegate icdControllerOneDocumentVC:strongSelf
                                          didSelectCopyData:strongSelf.data.fullDocument
                                                      times:numberOfCopies];
        }
    };
    
    RIButtonItem *continueItem = [RIButtonItem itemWithLabel:NSLocalizedString(@"Continue", @"Continue") action:continueAction];
    RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:NSLocalizedString(@"Cancel", @"Cancel")];
    
    alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Copy document", @"Copy document")
                                           message:NSLocalizedString(@"Set the number of copies", @"Set the number of copies")
                                  cancelButtonItem:cancelItem
                                  otherButtonItems:continueItem, nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    [alertView show];
}

- (void)replaceRightBarButtonsWithSaveBarButtonItem
{
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                          target:self
                                                                          action:@selector(checkJSONBeforeUpdatingDocument)];
    self.navigationItem.rightBarButtonItems = @[item];
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
                            documentId:(NSString *)documentId
{
    [self releaseData];
    
    _data = [[ICDControllerOneDocumentData alloc] initWithNetworkManager:networkManager
                                                            databaseName:databaseName
                                                              documentId:documentId];
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
