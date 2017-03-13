//
//  AboutWindowController.h
//  iSimulator
//
//  Created by Jakey on 2017/2/21.
//  Copyright © 2017年 Jakey. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AboutWindowController : NSWindowController
@property (weak) IBOutlet NSTextField *version;

- (IBAction)githubTouched:(id)sender;
- (IBAction)blogTouched:(id)sender;
@end
