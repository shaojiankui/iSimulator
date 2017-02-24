//
//  iTask.h
//  iSimulator
//
//  Created by Jakey on 2017/2/24.
//  Copyright © 2017年 Jakey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface iTask : NSObject
+ (NSString*)excute:(NSString*)commandPath arguments:(NSArray*)arguments;
@end
