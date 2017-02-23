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
#import "iDeviceGroup.h"
#import "iMenuItem.h"
#import "iAPP.h"
#import "iDevice.h"
#import "DirectoryWatcher.h"
@interface AppDelegate ()<NSMenuDelegate>

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    self.statusItem.menu = self.mainMenu;
    [DirectoryWatcher directoryDidChange:^(DirectoryWatcher *folderWatcher,NSString *watcherPath) {
        NSLog(@"changge");
        [[DirectoryWatcher sharedWatcher] cancleWithPath:watcherPath];
        [self showDeviceList];
    }];
    [self showDeviceList];
}
- (void)showDeviceList{
    
    NSDictionary *data = [[iSimulator shared] simulatorData];
    [self.mainMenu  removeAllItems];
    [self.mainMenu insertItem:[NSMenuItem separatorItem] atIndex:0];

    NSMutableArray *apps = [NSMutableArray array];
    for (NSInteger i = 0; i < [[data allKeys] count]; i++) {
        iDeviceGroup *deviceGroup = [[data allValues] objectAtIndex:i];

        if (deviceGroup.appCount >0) {
            iMenuItem *deviceubMenuItem = [[iMenuItem alloc] init];
            deviceubMenuItem.deviceGroup = deviceGroup;
            [deviceubMenuItem setTarget:self];
            deviceubMenuItem.title = deviceGroup.name;
            deviceubMenuItem.submenu = [[NSMenu alloc]init];
            
            for (iDevice *device in deviceGroup.items) {
                if ([device.items count]>0) {
                    iMenuItem *sandboxMenuItem = [[iMenuItem alloc] init];
                    sandboxMenuItem.device = device;
                    [sandboxMenuItem setTarget:self];
                    sandboxMenuItem.title = device.boxName;
                    sandboxMenuItem.submenu = [[NSMenu alloc]init];
                    
                    if ([device.items count]>0) {
                        for (iAPP *app in device.items) {
                            [apps addObject:app];
                            iMenuItem *appSubMenuItem = [[iMenuItem alloc] init];
                            appSubMenuItem.app = app;
                            appSubMenuItem.device = device;
                            [appSubMenuItem setTarget:self];
                            [appSubMenuItem setAction:@selector(gotoSandBox:)];
                            appSubMenuItem.title = app.appName?:@"";
                            [sandboxMenuItem.submenu addItem:appSubMenuItem];
                        }
                    }
                    [deviceubMenuItem.submenu addItem:sandboxMenuItem];
                }
            }
            [self.statusItem.menu insertItem:deviceubMenuItem atIndex:0];
        }
    }

    [self.statusItem.menu insertItem:[NSMenuItem separatorItem] atIndex:0];
    [apps sortUsingComparator:^NSComparisonResult(iAPP *  _Nonnull obj1, iAPP *  _Nonnull obj2) {
        return obj1.modifyDate < obj2.modifyDate;
    }];
    
    for (int i=0;i<[apps count]; i++) {
        if (5-i>=[apps count]) {
            continue;
        }
        if (5-i ==0) {
            break;
        }
        iAPP *app = [apps objectAtIndex:5-i];
        iMenuItem *appSubMenuItem = [[iMenuItem alloc] init];
        appSubMenuItem.app = app;
        [appSubMenuItem setTarget:self];
        [appSubMenuItem setAction:@selector(gotoSandBox:)];
        appSubMenuItem.title = app.appName?:@"";
        [self.statusItem.menu insertItem:appSubMenuItem atIndex:0];
    }
    [self.statusItem.menu insertItem:[NSMenuItem separatorItem] atIndex:0];
    
    [self beginDirectotyWatcher:data];

 
}
- (void)beginDirectotyWatcher:(NSDictionary*)data{
    [DirectoryWatcher watchFolderWithPath:[iSimulator simulatorPath]];

    for (NSInteger i = 0; i < [[data allKeys] count]; i++) {
        iDeviceGroup *deviceGroup = [[data allValues] objectAtIndex:i];
        
            for (iDevice *device in deviceGroup.items) {
                //具体模拟器
                [DirectoryWatcher watchFolderWithPath:[[iSimulator simulatorPath] stringByAppendingPathComponent:device.udid]];
                [DirectoryWatcher watchFolderWithPath:[[[iSimulator simulatorPath] stringByAppendingPathComponent:device.udid] stringByAppendingPathComponent:@"data"]];
                [DirectoryWatcher watchFolderWithPath:[[[iSimulator simulatorPath] stringByAppendingPathComponent:device.udid] stringByAppendingPathComponent:@"data/Containers/Bundle/Application"]];
//                for (iAPP *app in device.items) {
//
//                }
            }
        }
}
- (void)gotoSandBox:(iMenuItem*)item{
    if (!item.title.length) return ;
 
    [self openFinderWithFilePath:item.app.appSandBoxPath];
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
