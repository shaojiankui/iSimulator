//
//  iSimulator.m
//  iSimulator
//
//  Created by Jakey on 2016/03/27.
//  Copyright © 2016年 Jakey. All rights reserved.
//

#import "iSimulator.h"
#import "iSandBox.h"
#import "iDevice.h"
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
- (NSDictionary*)simulatorData
{
//    NSMutableArray *items = [NSMutableArray array];
    NSArray *plists = [self getDeviceInfoPlists];
    
    NSMutableDictionary *devices = [NSMutableDictionary dictionary];
    
    for (NSDictionary *dict in plists) {
        NSString *version = [[[dict valueForKeyPath:@"runtime"]   componentsSeparatedByString:@"."] lastObject] ;
        NSString *device = [dict valueForKeyPath:@"name"];
        
        NSString *boxName = [NSString stringWithFormat:@"%@ > (%@)",device, version];
        
        iSandBox *box = [[iSandBox alloc] init];
        if ([dict valueForKeyPath:@"UDID"]) {
            box.udid = dict[@"UDID"];
        }
        box.boxName = boxName;
        box.version = version;
        box.deviceName = device;
        box.items = [self projectsWithBox:box];
        
        iDevice *d;
        if (![devices objectForKey:device]) {
            d = [[iDevice alloc]init];
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
- (NSArray *)projectsWithBox:(iSandBox *)box{
    
    NSString *path = [self getDevicePath:box];
    NSMutableArray *projectSandBoxPath = [NSMutableArray array];
    
    NSArray *paths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
    for (NSString *pathName in paths) {
        NSString *fileName = [path stringByAppendingPathComponent:pathName];
        NSString *fileUrl = [self getDataDictPathWithFileName:fileName];
        
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:fileUrl];
        if ([dict valueForKeyPath:@"MCMMetadataIdentifier"]) {
            NSArray *array = [dict[@"MCMMetadataIdentifier"] componentsSeparatedByString:@"."];
            if (![dict[@"MCMMetadataIdentifier"] hasPrefix:@"com.apple"]) {
                NSString *projectName = [array lastObject];
                projectName = [projectName stringByReplacingOccurrencesOfString:@"-" withString:@"_"];
                iAPP *app = [[iAPP alloc]init];
                app.appName = projectName;
                app.appPath = fileName;
                [projectSandBoxPath addObject:app];
            }
        }
    }
    
    
    return projectSandBoxPath;
}
- (NSString *)getDevicePath:(iSandBox *)sandbox{
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:SIMULATOR_PATH]){
        return nil;
    }
    
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:SIMULATOR_PATH error:nil];
        NSString *ApplicationPath = nil;
    for (NSString *filesPath in files) {
        NSString *devicePath =  [[SIMULATOR_PATH stringByAppendingPathComponent:filesPath] stringByAppendingPathComponent:SIMULATOR_DEVICE];
        
        ApplicationPath =  [[[[[SIMULATOR_PATH stringByAppendingPathComponent:filesPath] stringByAppendingPathComponent:@"data"] stringByAppendingPathComponent:@"Containers"] stringByAppendingPathComponent:@"Data"] stringByAppendingPathComponent:@"Application"];
        
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:devicePath];
        
        if (dict.allKeys.count) {
            NSRange range = [[dict valueForKeyPath:@"UDID"] rangeOfString:sandbox.udid];
            if (range.location != NSNotFound) {
                if (![[NSFileManager defaultManager] fileExistsAtPath:ApplicationPath]) {
                    ApplicationPath =  [[[SIMULATOR_PATH stringByAppendingPathComponent:filesPath] stringByAppendingPathComponent:@"data"] stringByAppendingPathComponent:@"Applications"];
                    if (![[NSFileManager defaultManager] fileExistsAtPath:ApplicationPath]) {
                        return nil;
                    }
                }
                if (!ApplicationPath.length) {
                     ;
                    ApplicationPath = [[[SIMULATOR_PATH stringByAppendingPathComponent:filesPath] stringByAppendingPathComponent:@"data"] stringByAppendingPathComponent:@"Applications"];
                }
                return ApplicationPath;
            }
        }
    }
    
    return ApplicationPath;
}
- (NSString *)getDataDictPathWithFileName:(NSString *)fileName{
    return [fileName stringByAppendingPathComponent:@".com.apple.mobile_container_manager.metadata.plist"];
}

@end
