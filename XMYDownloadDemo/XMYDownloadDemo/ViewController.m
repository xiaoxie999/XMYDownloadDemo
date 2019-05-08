//
//  ViewController.m
//  XMYDownloadDemo
//
//  Created by apple on 2019/5/6.
//  Copyright © 2019 xiaoxie. All rights reserved.
//

#import "ViewController.h"
#import "DownloadManager.h"

#define WeakObj(o) autoreleasepool{} __weak typeof(o) o##Weak = o;

@interface ViewController () <NSURLSessionDelegate>

@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;

@property (nonatomic, assign) NSInteger currentIndex;

@property (nonatomic, strong) NSArray * requestArr;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.requestArr = [NSArray arrayWithObjects:
                       [NSURL URLWithString:@"http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4"],
                       [NSURL URLWithString:@"https://media.w3.org/2010/05/sintel/trailer.mp4"],
                       [NSURL URLWithString:@"http://mirror.aarnet.edu.au/pub/TED-talks/911Mothers_2010W-480p.mp4"],
                       nil];
    
    _currentIndex = 0;
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"com.xmy.background.identifier"];
    [configuration setNetworkServiceType:NSURLNetworkServiceTypeBackground];
    
    AFURLSessionManager * manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    @WeakObj(self);
    [manager setDidFinishEventsForBackgroundURLSessionBlock:^(NSURLSession * _Nonnull session) {
        NSLog(@"Background URL session %@ finished events.\n", session);
        if (session.configuration.identifier) {
            // 调用在 -application:handleEventsForBackgroundURLSession: 中保存的 handler
            
            NSString * identifier = session.configuration.identifier;
            void (^completionHandle)(void) = [[DownloadManager sharedDownloadManager].completionHandlerDictionary objectForKey:identifier];
            if (completionHandle) {
                [[DownloadManager sharedDownloadManager].completionHandlerDictionary removeObjectForKey: identifier];
                NSLog(@"Calling completion handler for session %@", identifier);
                completionHandle();
            }
        }
    }];
    
    [manager setTaskDidCompleteBlock:^(NSURLSession * _Nonnull session, NSURLSessionTask * _Nonnull task, NSError * _Nullable error) {
        if (!error) {
            [[DownloadManager sharedDownloadManager] taskComplete:(NSURLSessionDownloadTask*)task];
            
            [self refreshProgress:1.0f];
            
            selfWeak.currentIndex ++;
            if (selfWeak.currentIndex < selfWeak.requestArr.count) {
                [[selfWeak getTaskWithIndex:selfWeak.currentIndex] resume];
            }
        }
    }];
    
    [DownloadManager sharedDownloadManager].sessionManager = manager;
}

-(NSURLSessionDownloadTask *)getTaskWithIndex:(NSInteger)index {
    
    NSURL * url = _requestArr[index];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSessionDownloadTask * task = [[DownloadManager sharedDownloadManager].sessionManager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        
        CGFloat progressValue = 1.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount;
        NSLog(@"%f",progressValue);
        [self refreshProgress:progressValue];
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        //这里要返回一个NSURL，其实就是文件的位置路径
        NSString * path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        //使用建议的路径
        path = [path stringByAppendingPathComponent:response.suggestedFilename];
        return [NSURL fileURLWithPath:path];//转化为文件路径
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        
        //如果下载的是压缩包的话，可以在这里进行解压
//        NSLog(@"%@,%@,%@",response,filePath,error);
        //下载成功
        if (error == nil) {
            NSLog(@"%@",[filePath path]);
        }else{//下载失败的时候，只列举判断了两种错误状态码
            NSString * message = nil;
            if (error.code == - 1005) {
                message = @"网络异常";
            }else if (error.code == -1001){
                message = @"请求超时";
            }else{
                message = @"未知错误";
            }
        }
    }];
    task.taskDescription = [[url.absoluteString lastPathComponent] stringByDeletingPathExtension];
    
    return task;
}

- (IBAction)startDownload:(UIButton*)sender {
    sender.enabled = NO;
    
    [[self getTaskWithIndex:_currentIndex] resume];
}

-(void)refreshProgress:(CGFloat)progressValue {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressLabel.text = [NSString stringWithFormat:@"%.1f%%",progressValue*100];
        self.progressBar.progress = progressValue;
    });
}

@end
