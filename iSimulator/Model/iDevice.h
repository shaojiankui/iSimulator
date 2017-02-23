//
//  iDevice.h
//  iSimulator
//
//  Created by runlin on 2017/2/23.
//  Copyright © 2017年 Jakey. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "iAPP.h"

@interface iDevice : NSObject
@property (copy,nonatomic) NSString *udid;
@property (copy,nonatomic) NSString *version;
@property (copy,nonatomic) NSString *deviceName;
// device+version
@property (copy,nonatomic) NSString *boxName;
// contains simulator items
@property (strong,nonatomic) NSArray<iAPP*> *items;
// sanbox path
//@property (strong,nonatomic) NSArray *projectSandBoxPath;
@end
