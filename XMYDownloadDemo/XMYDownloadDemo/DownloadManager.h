//
//  DownloadManager.h
//  XMYDownloadDemo
//
//  Created by apple on 2019/5/8.
//  Copyright © 2019 xiaoxie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

NS_ASSUME_NONNULL_BEGIN

//typedef void (^HandlerBlock)(void);

@interface DownloadManager : NSObject

+(DownloadManager *)sharedDownloadManager;

@property (nonatomic, strong) AFURLSessionManager * sessionManager;

@property (nonatomic, strong) NSMutableDictionary * completionHandlerDictionary;

-(void)taskComplete:(NSURLSessionDownloadTask*)task;

@end

NS_ASSUME_NONNULL_END
