/*
     File: DirectoryWatcher.m 
 Abstract: 
 Object used to monitor the contents of a given directory by using
 "kqueue": a kernel event notification mechanism.
  
  Version: 1.6 
  
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple 
 Inc. ("Apple") in consideration of your agreement to the following 
 terms, and your use, installation, modification or redistribution of 
 this Apple software constitutes acceptance of these terms.  If you do 
 not agree with these terms, please do not use, install, modify or 
 redistribute this Apple software. 
  
 In consideration of your agreement to abide by the following terms, and 
 subject to these terms, Apple grants you a personal, non-exclusive 
 license, under Apple's copyrights in this original Apple software (the 
 "Apple Software"), to use, reproduce, modify and redistribute the Apple 
 Software, with or without modifications, in source and/or binary forms; 
 provided that if you redistribute the Apple Software in its entirety and 
 without modifications, you must retain this notice and the following 
 text and disclaimers in all such redistributions of the Apple Software. 
 Neither the name, trademarks, service marks or logos of Apple Inc. may 
 be used to endorse or promote products derived from the Apple Software 
 without specific prior written permission from Apple.  Except as 
 expressly stated in this notice, no other rights or licenses, express or 
 implied, are granted by Apple herein, including but not limited to any 
 patent rights that may be infringed by your derivative works or by other 
 works in which the Apple Software may be incorporated. 
  
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE 
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION 
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS 
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND 
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 
  
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL 
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, 
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED 
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), 
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE 
 POSSIBILITY OF SUCH DAMAGE. 
  
 Copyright (C) 2014 Apple Inc. All Rights Reserved. 
  
 */ 

#import "DirectoryWatcher.h"

#include <sys/types.h>
#include <sys/event.h>
#include <sys/time.h>
#include <fcntl.h>
#include <unistd.h>

#import <CoreFoundation/CoreFoundation.h>


#pragma mark -

@implementation DirectoryWatcher
+ (void)directoryDidChange:(DirectoryDidChange)directoryDidChange{
    [self sharedWatcher]-> _directoryDidChange = [directoryDidChange copy];
}

+ (DirectoryWatcher*)sharedWatcher
{
    static DirectoryWatcher *sharedWatcher = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedWatcher = [[DirectoryWatcher alloc] init];
    });
    return sharedWatcher;
}

- (void)dealloc
{
	[self cancle];
}

+ (DirectoryWatcher *)watchFolderWithPath:(NSString *)watchPath
{
    DirectoryWatcher *tempManager = [self sharedWatcher];
	if ((tempManager->_directoryDidChange != NULL) && [[NSFileManager defaultManager] fileExistsAtPath:watchPath] && ![tempManager.watchers objectForKey:watchPath])
	{
//        NSLog(@"\nwatchFolderWithPath:%@",watchPath);
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        int fildes = open([watchPath UTF8String], O_EVTONLY);
        if (fildes < 0) {
            char buffer[80];
            strerror_r(errno, buffer, sizeof(buffer));
            NSLog(@"Unable to open \"%@\": %s (%d)", watchPath, buffer, errno);
            return tempManager;
        }
        __block dispatch_source_t source = dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE,fildes,
                                                                  DISPATCH_VNODE_DELETE | DISPATCH_VNODE_WRITE | DISPATCH_VNODE_EXTEND | DISPATCH_VNODE_ATTRIB | DISPATCH_VNODE_LINK | DISPATCH_VNODE_RENAME | DISPATCH_VNODE_REVOKE,
                                                                  queue);
        dispatch_source_set_event_handler(source, ^
                                          {
                                              unsigned long flags = dispatch_source_get_data(source);
                                              if(flags & DISPATCH_VNODE_WRITE || flags & DISPATCH_VNODE_DELETE)
                                              {
                                                  if (tempManager->_directoryDidChange) {
                                                      tempManager->_directoryDidChange(tempManager,watchPath);
                                                  }
                                              }
                                              // Reload config file
                                          });
        dispatch_source_set_cancel_handler(source, ^(void) 
                                           {
                                               close(fildes);
                                           });
        dispatch_resume(source);
        
        if (!tempManager.watchers) {
            tempManager.watchers = [NSMutableDictionary dictionary];
        }
        [tempManager.watchers setObject:source forKey:watchPath];
 
	}
	return tempManager;
}

- (void)cancle
{
    for (dispatch_source_t source in self.watchers) {
        dispatch_source_cancel(source);
    }
    [self.watchers removeAllObjects];
}
- (void)cancleWithPath:(NSString*)path{
    dispatch_source_cancel([self.watchers objectForKey:path]);
    [self.watchers removeObjectForKey:path];

}
@end
