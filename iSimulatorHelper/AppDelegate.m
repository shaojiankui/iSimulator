//
//  AppDelegate.m
//  iSimulatorHelper
//
//  Created by runlin on 2017/2/24.
//  Copyright © 2017年 Jakey. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSString *mainAPP = @"org.skyfox.iSimulator";
    
    //launchctl print-disabled "user/$(id -u)"
    
//    NSArray *runningArray = [NSRunningApplication runningApplicationsWithBundleIdentifier:mainAPP];
    BOOL alreadRunning = NO;
    NSArray *runnings = [NSWorkspace sharedWorkspace].runningApplications;
    for (NSRunningApplication *app in runnings) {
        if ([app.bundleIdentifier isEqualToString:mainAPP]) {
            alreadRunning = YES;
            break;
        }
    }
    
    if (!alreadRunning) {
        [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                                            selector:@selector(terminate) name:@"killme" object:mainAPP];
        
        NSString *appPath = [[NSBundle mainBundle] bundlePath];
        appPath = [appPath stringByReplacingOccurrencesOfString:@"/Contents/Library/LoginItems/iSimulatorHelper.app" withString:@""];
        appPath = [appPath stringByAppendingPathComponent:@"Contents/MacOS/iSimulator"];

        if (![[NSFileManager defaultManager] fileExistsAtPath:appPath])
        {
            return;
        }
        NSLog(@"iSimulatorHelper launchApplication");
        [[NSWorkspace sharedWorkspace] launchApplication:appPath];
    }else{
         [self terminate];
    }
}

- (void)terminate{
    [NSApp terminate:nil];
    NSLog(@"iSimulatorHelper terminate");

}
- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
