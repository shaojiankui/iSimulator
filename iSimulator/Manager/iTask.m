//
//  iTask.m
//  iSimulator
//
//  Created by Jakey on 2017/2/24.
//  Copyright © 2017年 Jakey. All rights reserved.
//

#import "iTask.h"

@implementation iTask
+ (NSString*)excute:(NSString*)commandPath arguments:(NSArray*)arguments{
    NSTask *task;
    task = [[NSTask alloc] init];
    [task setLaunchPath:commandPath];
    [task setArguments:arguments];
    
    NSPipe *pipe;
    pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];   //设置输出参数
    
    NSFileHandle *file;
    file = [pipe fileHandleForReading];   // 句柄
    
    [task launch];
    
    NSData *data;
    data = [file readDataToEndOfFile];  // 读取数据
    
    NSString *string;
    string = [[NSString alloc] initWithData: data
                                   encoding: NSUTF8StringEncoding];
    NSLog (@"excute respone:\n%@", string);
    return string;
    
//    NSString *command = [[commandPath stringByAppendingString:@" "] stringByAppendingString:[arguments componentsJoinedByString:@" "]];
//    system([command cStringUsingEncoding:NSUTF8StringEncoding]);
}
@end
