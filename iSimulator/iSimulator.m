//
//  iSimulator.m
//  iSimulator
//
//  Created by Jakey on 2016/03/27.
//  Copyright © 2016年 Jakey. All rights reserved.
//

#import "iSimulator.h"

#import "iDeviceGroup.h"
#import "iDevice.h"
#import "STPrivilegedTask.h"
#import "iTask.h"
#define SIMULATOR_PATH [NSString stringWithFormat:@"%@/Library/Developer/CoreSimulator/Devices/", RealHomeDirectory()]

#define SIMULATOR_DEVICE @"device.plist"

@implementation iSimulator
+ (instancetype)shared
{
    static iSimulator *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[iSimulator alloc] init];
    });
    return shared;
}

- (instancetype)init
{
    self = [super init];
    if (self) {

    }
    return self;
}
+ (NSString*)simulatorPath{
    return SIMULATOR_PATH;
}
- (NSDictionary*)simulatorData
{
//    NSMutableArray *items = [NSMutableArray array];
    NSArray *plists = [self getDeviceInfoPlists];
    
    NSMutableDictionary *devices = [NSMutableDictionary dictionary];
    
    for (NSDictionary *dict in plists) {
        NSString *version = [[[dict valueForKeyPath:@"runtime"]   componentsSeparatedByString:@"."] lastObject] ;
        NSString *device = [dict valueForKeyPath:@"name"];
        
        NSString *boxName = [NSString stringWithFormat:@"%@ > (%@)",device, version];
        
        iDevice *box = [[iDevice alloc] init];
        if ([dict valueForKeyPath:@"UDID"]) {
            box.udid = dict[@"UDID"];
        }
        box.boxName = boxName;
        box.version = version;
        box.deviceName = device;
        box.items = [self appsWithBox:box];
        
        iDeviceGroup *d;
        if (![devices objectForKey:device]) {
            d = [[iDeviceGroup alloc]init];
            d.items  = @[box];
            d.appCount = 0;
            [devices setObject:d forKey:device];
        }else{
            d = [devices objectForKey:device];
            NSMutableArray *array = [d.items mutableCopy];
            [array addObject:box];
            d.items = [array copy];
        }
        d.name = device;
        d.appCount += [box.items count];

//        [items addObject:box];
    }
    
    return devices;
}
- (NSArray *)getDeviceInfoPlists{
    
    NSMutableArray *plists = [NSMutableArray array];
    if([[NSFileManager defaultManager] fileExistsAtPath:SIMULATOR_PATH]){
        NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:SIMULATOR_PATH error:nil];
         for (NSString *filesPath in files) {
            NSString *devicePath =  [[SIMULATOR_PATH stringByAppendingPathComponent:filesPath] stringByAppendingPathComponent:SIMULATOR_DEVICE];
            if (![[NSFileManager defaultManager] fileExistsAtPath:devicePath]) {
                continue;
            }
            NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:devicePath];
            if (dict.allKeys.count) {
                [plists addObject:dict];
            }
         }
    }
    return plists;
}
#pragma mark - util
NSString *RealHomeDirectory() {
    //    struct passwd *pw = getpwuid(getuid());
    //    assert(pw);
    //    return [NSString stringWithUTF8String:pw->pw_dir];
    //
    NSString *home = NSHomeDirectory();
    NSArray *pathArray = [home componentsSeparatedByString:@"/"];
    NSString *absolutePath;
    if ([pathArray count] > 2) {
        absolutePath = [NSString stringWithFormat:@"/%@/%@", [pathArray objectAtIndex:1], [pathArray objectAtIndex:2]];
    }
    return absolutePath;
}
- (NSArray *)appsWithBox:(iDevice *)device{
    
    NSString *deviceAppBundlePath = [[SIMULATOR_PATH stringByAppendingPathComponent:device.udid] stringByAppendingPathComponent:@"data/Containers/Bundle/Application"];

    
    NSMutableArray *appsSandBoxPaths = [NSMutableArray array];
    
//    NSArray *paths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:deviceAppBundlePath error:nil];
    NSArray *paths = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[NSURL fileURLWithPath:deviceAppBundlePath] includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsSubdirectoryDescendants|NSDirectoryEnumerationSkipsHiddenFiles error:nil];

    for (NSURL *appPathURL in paths) {
        NSDictionary *infoDict = [self appPlistInfo:[appPathURL absoluteString]];
        iAPP *app = [[iAPP alloc]init];
        app.appName =  [infoDict valueForKey:@"CFBundleDisplayName"]?:  [infoDict valueForKey:@"CFBundleName"];
        app.bundleID = [infoDict valueForKey:@"CFBundleIdentifier"];
        //                app.UUID = [dict valueForKey:@"MCMMetadataUUID"];
        app.version = [infoDict valueForKey:@"CFBundleShortVersionString"];
        app.build = [infoDict valueForKey:@"CFBundleVersion"];
        app.UUID = device.udid;
        id modifyDate;
        [appPathURL getResourceValue:&modifyDate
                                                  forKey:NSURLContentModificationDateKey
                                                   error:NULL];
        app.modifyDate = [modifyDate timeIntervalSince1970];
        app.appBundlePath = [appPathURL absoluteString];
        app.appSandBoxPath = [self appSandBoxPath:app];
        [appsSandBoxPaths addObject:app];
    }
    return appsSandBoxPaths;
}
-(NSDictionary*)appPlistInfo:(NSString*)appDir{
    NSArray *enumerator = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[NSURL URLWithString:appDir] includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsSubdirectoryDescendants|NSDirectoryEnumerationSkipsHiddenFiles error:nil];
    NSURL *appInfoPlist = [enumerator.lastObject URLByAppendingPathComponent:@"Info.plist"];
    NSDictionary *infoDict = [NSDictionary dictionaryWithContentsOfURL:appInfoPlist];
    return infoDict;
}
- (NSString *)appSandBoxPath:(iAPP *)app
{
    NSString *deviceApplicationPath = [[SIMULATOR_PATH stringByAppendingPathComponent:app.UUID] stringByAppendingPathComponent:@"data/Containers/Data/Application"];

    NSArray *paths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:deviceApplicationPath error:nil];
    NSString *appPath;
    for (NSString *appPathName in paths) {
        NSString *p = [deviceApplicationPath stringByAppendingPathComponent:appPathName];
        
        NSString *fileUrl = [p stringByAppendingPathComponent:@".com.apple.mobile_container_manager.metadata.plist"];

        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:fileUrl];
        if ([[dict valueForKeyPath:@"MCMMetadataIdentifier"] isEqualToString:app.bundleID]){
            appPath = p;
            break;
        }
    }

    return appPath;
}
#pragma mark -- app opration
- (void)openFinderWithFilePath:(NSString *)path{
    if (!path.length) {
        return ;
    }
//    NSString *open = [NSString stringWithFormat:@"open %@",path];
//    const char *str = [open UTF8String];
//    system(str);
    [[NSWorkspace sharedWorkspace] openURL:[NSURL fileURLWithPath:path]];
}

- (void)revealAppInSandbox:(iAPP *)app
{
    [self openFinderWithFilePath:app.appSandBoxPath];
}
- (void)resetStoreData:(iAPP *)app
{
    [self deletePathDataWithOutOwenFolder:[app.appSandBoxPath stringByAppendingPathComponent:@"Documents"]];
    [self deletePathDataWithOutOwenFolder:[app.appSandBoxPath stringByAppendingPathComponent:@"Library"]];
    [self deletePathDataWithOutOwenFolder:[app.appSandBoxPath stringByAppendingPathComponent:@"tmp"]];
}
- (void)launchInSimulator:(iAPP *)app
{
//    [STPrivilegedTask launchedPrivilegedTaskWithLaunchPath:@"/usr/bin/xcrun" arguments:@[@"instruments",@"-w",app.UUID]];
//    [STPrivilegedTask launchedPrivilegedTaskWithLaunchPath:@"/usr/bin/xcrun" arguments:@[@"simctl",@"launch",@"booted",app.bundleID]];
    __unused NSString *string =  [iTask excute:@"/usr/bin/xcrun" arguments:@[@"instruments", @"-w", app.UUID]];
    __unused NSString *string2 =   [iTask excute:@"/usr/bin/xcrun" arguments:@[@"simctl",@"launch",@"booted",app.bundleID]];

    
}
- (void)uninstallFromeSimulator:(iAPP *)app{
    __unused NSString *string =  [iTask excute:@"/usr/bin/xcrun" arguments:@[@"instruments", @"-w", app.UUID]];
    __unused NSString *string2 =   [iTask excute:@"/usr/bin/xcrun" arguments:@[@"simctl",@"terminate",app.UUID,app.bundleID]];
    __unused NSString *string3 =   [iTask excute:@"/usr/bin/xcrun" arguments:@[@"simctl",@"uninstall",@"booted",app.bundleID]];
}
- (void)deletePathDataWithOutOwenFolder:(NSString*)path{
    if (!path || path.length<=0) {
        return;
    }
    NSFileManager *defaultManger = [NSFileManager defaultManager];
    
    NSArray *contents = [defaultManger contentsOfDirectoryAtPath:path error:NULL];
    NSEnumerator*e = [contents objectEnumerator];
    NSString *filename;
    while ((filename = [e nextObject])) {
        [defaultManger removeItemAtPath:[path stringByAppendingPathComponent:filename] error:NULL];
    }
}
@end
