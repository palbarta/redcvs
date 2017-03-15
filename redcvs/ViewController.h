//
//  ViewController.h
//  redcvs
//
//  Created by Barta Pál on 2017. 03. 12..
//  Copyright © 2017. Barta Pál. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController

@property (weak) IBOutlet NSTextView *textView;
@property (weak) IBOutlet NSTextField *targetFileOrDir;
@property (weak) IBOutlet NSButton *browseButton;

- (IBAction)browseButtonClicked:(NSButton *)sender;
- (IBAction)saveButtonClicked:(NSButton *)sender;


@end

