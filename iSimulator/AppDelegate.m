//
//  AppDelegate.m
//  iSimulator
//
//  Created by Jakey on 2016/03/27.
//  Copyright © 2016年 Jakey. All rights reserved.
//

#import "AppDelegate.h"
#import "AboutWindowController.h"
#import "PreferencesWindowController.h"

#import "iSimulator.h"
#import "iSandBox.h"
#import "iMenuItem.h"
#import "iAPP.h"
#import "iDevice.h"
@interface AppDelegate ()<NSMenuDelegate>

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    self.statusItem.menu = self.mainMenu;
    [self showDeviceList];
}
- (void)showDeviceList{
    NSDictionary *data = [[iSimulator shared] simulatorData];
    [self.mainMenu insertItem:[NSMenuItem separatorItem] atIndex:0];

    for (NSInteger i = 0; i < [[data allKeys] count]; i++) {
        iDevice *device = [[data allValues] objectAtIndex:i];

        if (device.appCount >0) {
            iMenuItem *deviceubMenuItem = [[iMenuItem alloc] init];
            deviceubMenuItem.device = device;
            [deviceubMenuItem setTarget:self];
            deviceubMenuItem.title = device.name;
            deviceubMenuItem.submenu = [[NSMenu alloc]init];
            
            for (iSandBox *sandbox in device.items) {
                if ([sandbox.items count]>0) {
                    iMenuItem *sandboxMenuItem = [[iMenuItem alloc] init];
                    sandboxMenuItem.sandbox = sandbox;
                    [sandboxMenuItem setTarget:self];
                    sandboxMenuItem.title = sandbox.boxName;
                    sandboxMenuItem.submenu = [[NSMenu alloc]init];
                    
                    if ([sandbox.items count]>0) {
                        for (iAPP *app in sandbox.items) {
                            iMenuItem *appSubMenuItem = [[iMenuItem alloc] init];
                            appSubMenuItem.app = app;
                            appSubMenuItem.sandbox = sandbox;
                            [appSubMenuItem setTarget:self];
                            [appSubMenuItem setAction:@selector(gotoSandBox:)];
                            appSubMenuItem.title = app.appName;
                            [sandboxMenuItem.submenu addItem:appSubMenuItem];;
                        }
                    }
                    [deviceubMenuItem.submenu addItem:sandboxMenuItem];
                }
            }
            [self.statusItem.menu insertItem:deviceubMenuItem atIndex:0];
        }
    }

}
- (void)gotoSandBox:(iMenuItem*)item{
    if (!item.title.length) return ;
 
    [self openFinderWithFilePath:item.app.appPath];
}
- (void)openFinderWithFilePath:(NSString *)path{
    if (!path.length) {
        return ;
    }
    NSString *open = [NSString stringWithFormat:@"open %@",path];
    const char *str = [open UTF8String];
    system(str);
}
- (NSWindowController *)aboutWindowController{
    if (!_aboutWindowController) {
        _aboutWindowController = [[AboutWindowController alloc] initWithWindowNibName:@"AboutWindowController"];
        [_aboutWindowController.window orderFrontRegardless];
    }
    return  _aboutWindowController;
}
- (NSWindowController *)preferencesWindowController{
    if (!_preferencesWindowController) {
        _preferencesWindowController = [[PreferencesWindowController alloc] initWithWindowNibName:@"PreferencesWindowController"];
        [_preferencesWindowController.window orderFrontRegardless];
    }
    return  _preferencesWindowController;
}
-(NSStatusItem *)statusItem{
    if (!_statusItem) {
        _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
        [_statusItem setImage:[NSImage imageNamed:@"iSimulator"]];
        [_statusItem setHighlightMode:YES];
    }
    return _statusItem;
}
- (NSMenu *)mainMenu{
    if (!_mainMenu) {
        _mainMenu = [[NSMenu alloc] initWithTitle:@"xxxx"];
        
        NSMenuItem *aboutItem  = [[NSMenuItem alloc] initWithTitle:@"About iSimulators" action:@selector(aboutItemTouched:) keyEquivalent:@"a"];
        aboutItem.target = self;
        [_mainMenu addItem:aboutItem];
        
        NSMenuItem *preferencesItem  = [[NSMenuItem alloc] initWithTitle:@"Preferences..." action:@selector(preferencesItemTouched:) keyEquivalent:@","];
        preferencesItem.target = self;
        [_mainMenu addItem:preferencesItem];
        
        [_mainMenu addItem:[NSMenuItem separatorItem]];
        
        NSMenuItem *exitItem  = [[NSMenuItem alloc] initWithTitle:@"Quit iSimulators" action:@selector(exitItemTouched:) keyEquivalent:@"q"];
        exitItem.target = self;
        [_mainMenu addItem:exitItem];
        _mainMenu.delegate = self;
    }
    return _mainMenu;
}

#pragma mark -- MainMenu
- (void)aboutItemTouched:(NSMenuItem *)item
{
    [NSApp activateIgnoringOtherApps:YES];
    [self.aboutWindowController showWindow:self];
}
- (void)preferencesItemTouched:(NSMenuItem *)item
{
    [NSApp activateIgnoringOtherApps:YES];
    [self.preferencesWindowController showWindow:self];
}
- (void)exitItemTouched:(NSMenuItem *)item
{
    [NSApp terminate:self];
}

@end
