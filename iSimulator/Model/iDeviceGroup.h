//
//  iDevice.h
//  iSimulator
//
//  Created by Jakey on 2017/2/21.
//  Copyright © 2017年 Jakey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iDevice.h"
@interface iDeviceGroup : NSObject
@property (copy,nonatomic) NSString *name;
@property (assign,nonatomic) NSInteger *appCount;
@property (strong,nonatomic) NSArray<iDevice*> *items;
@end
