//
//  iSimulator.h
//  iSimulator
//
//  Created by Jakey on 2016/03/27.
//  Copyright © 2016年 Jakey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "iDevice.h"
@interface iSimulator : NSObject
+ (instancetype)shared;
+ (NSString*)simulatorPath;
- (NSDictionary*)simulatorData;
//- (NSString *)getDevicePath:(iSandBox *)sandbox;

#pragma mark -- app opration
- (void)openFinderWithFilePath:(NSString *)path;
- (void)revealAppInSandbox:(iAPP *)app;
- (void)resetStoreData:(iAPP *)app;
- (void)launchInSimulator:(iAPP *)app;
- (void)uninstallFromeSimulator:(iAPP *)app;
@end
