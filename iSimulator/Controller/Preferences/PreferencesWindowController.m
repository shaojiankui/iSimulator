//
//  PreferencesWindowController.m
//  iSimulator
//
//  Created by Jakey on 2017/2/21.
//  Copyright © 2017年 Jakey. All rights reserved.
//

#import "PreferencesWindowController.h"

@interface PreferencesWindowController ()

@end

@implementation PreferencesWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
//     [self.itSwitch bind:@"checked" toObject:self withKeyPath:@"bindableFlag" options:nil];
    NSString *launchFolder = [NSString stringWithFormat:@"%@/Library/LaunchAgents",NSHomeDirectory()];
    NSString *boundleID = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleIdentifierKey];
    NSString *dstLaunchPath = [launchFolder stringByAppendingFormat:@"/%@.plist",boundleID];
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDir = NO;
    if ([fm fileExistsAtPath:dstLaunchPath isDirectory:&isDir] && !isDir) {
        self.itSwitch.checked = YES;
    }
    
}
- (IBAction)switchChanged:(ITSwitch *)itSwitch {
    NSLog(@"Switch (%@) is %@", itSwitch, itSwitch.checked ? @"checked" : @"unchecked");
    if(itSwitch.checked)
    {
        [self installDaemon];
    }
    else
    {
        [self unInstallDaemon];
    }
}
//http://www.cnblogs.com/watchdatalearn2012620/p/3336414.html

-(void)installDaemon{
    NSString *launchFolder = [NSString stringWithFormat:@"%@/Library/LaunchAgents",NSHomeDirectory()];
    NSString *boundleID = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleIdentifierKey];
    NSString *dstLaunchPath = [launchFolder stringByAppendingFormat:@"/%@.plist",boundleID];
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDir = NO;
    //已经存在启动项中，就不必再创建
    if ([fm fileExistsAtPath:dstLaunchPath isDirectory:&isDir] && !isDir) {
        return;
    }
    //下面是一些配置
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    NSMutableArray* arr = [[NSMutableArray alloc] init];
    [arr addObject:[[NSBundle mainBundle] executablePath]];
    [arr addObject:@"-runMode"];
    [arr addObject:@"autoLaunched"];
    [dict setObject:[NSNumber numberWithBool:true] forKey:@"RunAtLoad"];
    [dict setObject:boundleID forKey:@"Label"];
    [dict setObject:arr forKey:@"ProgramArguments"];
    isDir = NO;
    if (![fm fileExistsAtPath:launchFolder isDirectory:&isDir] && isDir) {
        [fm createDirectoryAtPath:launchFolder withIntermediateDirectories:NO attributes:nil error:nil];
    }
    [dict writeToFile:dstLaunchPath atomically:NO];
 
}
-(void)unInstallDaemon{
    NSString* launchFolder = [NSString stringWithFormat:@"%@/Library/LaunchAgents",NSHomeDirectory()];
    BOOL isDir = NO;
    NSFileManager* fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:launchFolder isDirectory:&isDir] && isDir) {
        return;
    }
    NSString * boundleID = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleIdentifierKey];
    NSString* srcLaunchPath = [launchFolder stringByAppendingFormat:@"/%@.plist",boundleID];
    [fm removeItemAtPath:srcLaunchPath error:nil];
}
//
//- (void)windowDidLoad {
//    [super windowDidLoad];
//    //     [self.itSwitch bind:@"checked" toObject:self withKeyPath:@"bindableFlag" options:nil];
//    self.itSwitch.checked = [self isStartAtLogin];
//}
//- (BOOL)isStartAtLogin {
//    NSDictionary *dict = (__bridge NSDictionary*)SMJobCopyDictionary(kSMDomainUserLaunchd,
//                                                                     CFSTR("org.skyfox.iSimulatorHelper"));
//    BOOL contains = (dict!=NULL);
//    return contains;
//}
//- (IBAction)switchChanged:(ITSwitch *)itSwitch {
//    NSLog(@"Switch (%@) is %@", itSwitch, itSwitch.checked ? @"checked" : @"unchecked");
//    if(itSwitch.checked)
//    {
//        [self daemon:YES];
//    }
//    else
//    {
//        [self daemon:NO];
//    }
//}
////开启Sandbox后，请求网络数据出现"The connection to service named com.apple.nsurlstorage-cache was invalidated." 错误。勾选App Sandbox中Outgoing Connections(Client)
//-(void)daemon:(Boolean)install{
//    
//    NSString *helperPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Contents/Library/LoginItems/iSimulatorHelper.app"];
//    if (![[NSFileManager defaultManager] fileExistsAtPath:helperPath])
//    {
//        return;
//    }
//    NSURL *helperUrl = [NSURL fileURLWithPath:helperPath];
//    // Registering helper app
//    if (LSRegisterURL((__bridge CFURLRef)helperUrl, true) != noErr)
//    {
//        NSLog(@"LSRegisterURL failed!");
//    }
//    // Setting login
//    // com.xxx.xxx为Helper的BundleID,ture/false设置开启还是关闭
//    if (!SMLoginItemSetEnabled((CFStringRef)@"org.skyfox.iSimulatorHelper",install))
//    {
//        NSLog(@"SMLoginItemSetEnabled failed!");
//    }
//    
//    NSString *mainAPP = [NSBundle mainBundle].bundleIdentifier?:@"org.skyfox.iSimulator";
//    BOOL alreadRunning = NO;
//    NSArray *runnings = [NSWorkspace sharedWorkspace].runningApplications;
//    for (NSRunningApplication *app in runnings) {
//        if ([app.bundleIdentifier isEqualToString:mainAPP]) {
//            alreadRunning = YES;
//            break;
//        }
//    }
//    
//    if (alreadRunning) {
//        [[NSDistributedNotificationCenter defaultCenter]postNotificationName:@"killme" object:[NSBundle mainBundle].bundleIdentifier];
//    }
//}

@end
