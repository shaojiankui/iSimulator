//
//  AppDelegate.h
//  iSimulator
//
//  Created by Jakey on 2016/03/27.
//  Copyright © 2016年 Jakey. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@interface AppDelegate : NSObject <NSApplicationDelegate>
@property (nonatomic, strong) NSWindowController *aboutWindowController;
@property (nonatomic, strong) NSWindowController *preferencesWindowController;
@property (nonatomic, strong) NSMenu *mainMenu;
@property (nonatomic, strong) NSStatusItem *statusItem;
@end

