//
//  iAPP.h
//  iSimulator
//
//  Created by Jakey on 2017/2/21.
//  Copyright © 2017年 Jakey. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface iAPP : NSObject
@property (copy,nonatomic) NSString *appName;
@property (copy,nonatomic) NSString *appBundlePath;
@property (copy,nonatomic) NSString *appSandBoxPath;

@property (copy,nonatomic) NSString *deviceName;
@property (copy,nonatomic) NSString *deviceVersion;

@property (copy,nonatomic) NSString *bundleID;
@property (copy,nonatomic) NSString *UUID;
@property (copy,nonatomic) NSString *version;
@property (copy,nonatomic) NSString *build;
@property (copy,nonatomic) NSString *appIcon;
@property (assign,nonatomic) long long modifyDate;


@end
