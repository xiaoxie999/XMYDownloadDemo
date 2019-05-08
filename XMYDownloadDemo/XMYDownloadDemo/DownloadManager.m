//
//  DownloadManager.m
//  XMYDownloadDemo
//
//  Created by apple on 2019/5/8.
//  Copyright © 2019 xiaoxie. All rights reserved.
//

#import "DownloadManager.h"

@implementation DownloadManager

+(DownloadManager *)sharedDownloadManager {
    static DownloadManager * sharedDownloadManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDownloadManager = [[DownloadManager alloc] init];
    });
    return sharedDownloadManager;
}

-(instancetype)init
{
    if (self = [super init]) {
        _completionHandlerDictionary = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    return self;
}

-(void)taskComplete:(NSURLSessionDownloadTask*)task {
    
    dispatch_async(dispatch_get_main_queue(), ^{
//        if (UIApplication.sharedApplication.applicationState == UIApplicationStateBackground)
        {
            UILocalNotification *localNoti = [[UILocalNotification alloc] init];
                localNoti.fireDate=[NSDate dateWithTimeIntervalSinceNow:2.0f];
            localNoti.soundName = UILocalNotificationDefaultSoundName;
            localNoti.alertTitle = [NSString stringWithFormat:@"%@下载完成",task.taskDescription];
            localNoti.alertBody = @"";
            localNoti.applicationIconBadgeNumber = 1;
            localNoti.timeZone = [NSTimeZone defaultTimeZone];
            localNoti.soundName = UILocalNotificationDefaultSoundName;
            
//            [[UIApplication sharedApplication] presentLocalNotificationNow:localNoti];
            [[UIApplication sharedApplication] scheduleLocalNotification:localNoti];
        }
    });
}

@end
