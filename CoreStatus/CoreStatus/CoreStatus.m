//
//  CoreNetWorkStatusObserver.m
//  CoreNetWorkStatusObserver
//
//  Created by LiHaozhen on 15/5/2.
//  Copyright (c) 2015年 ihojin. All rights reserved.
//

#import "CoreStatus.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>


static NSString *const CoreStatusChangedNoti = @"CoreStatusChangedNoti";


@interface CoreStatus ()
/** Block容器 */
@property (nonatomic,strong) NSMutableDictionary *blockDict;

/** 2G数组 */
@property (nonatomic,strong) NSArray *technology2GArray;

/** 3G数组 */
@property (nonatomic,strong) NSArray *technology3GArray;

/** 4G数组 */
@property (nonatomic,strong) NSArray *technology4GArray;

/** 网络状态中文数组 */
@property (nonatomic,strong) NSArray *coreNetworkStatusStringArray;

@property (nonatomic,strong) Reachability *reachability;

@property (nonatomic,copy) NSString *currentRadioAccessTechnology;

/** 是否正在监听 */
@property (nonatomic,assign) BOOL isNoti;

@end




@implementation CoreStatus
+ (instancetype)sharedCoreStatus{
    
    static CoreStatus *_instace = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instace = [[CoreStatus alloc] init];
        [_instace setup];
    });
    return _instace;
}

#pragma mark - Class Methods
/** 获取当前网络状态：枚举 */
+(CoreNetWorkStatus)currentNetWorkStatus{
    
    CoreStatus *status = [CoreStatus sharedCoreStatus];

    return [status statusWithRadioAccessTechnology];
}


/** 获取当前网络状态：字符串 */
+(NSString *)currentNetWorkStatusString{
    
    CoreStatus *status = [CoreStatus sharedCoreStatus];
    
    return status.coreNetworkStatusStringArray[[self currentNetWorkStatus]];
}

/** 开始网络监听 */
+(void)addNetworkStatusListener:(NSString *)listenerName withDidChangeBlock:(CSStatusDidChangedBlock)block{
    CoreStatus *status = [CoreStatus sharedCoreStatus];
    if (listenerName && block) {
        block([CoreStatus currentNetWorkStatusString],[CoreStatus currentNetWorkStatus]);
        [status.blockDict setObject:block forKey:listenerName];
    }
}

/** 移除网络监听 */
+(void)removeNetworkStatusListener:(NSString *)listenerName{
    CoreStatus *status = [CoreStatus sharedCoreStatus];
    [status.blockDict removeObjectForKey:listenerName];
}

/** 是否是Wifi */
+(BOOL)isWifiEnable{
    
    return [self currentNetWorkStatus] == CoreNetWorkStatusWifi;
}


/** 是否有网络 */
+(BOOL)isNetworkEnable{
    
    CoreNetWorkStatus networkStatus = [self currentNetWorkStatus];
    
    return networkStatus!=CoreNetWorkStatusUnkhow && networkStatus != CoreNetWorkStatusNone;
}

/** 是否处于高速网络环境：3G、4G、Wifi */
+(BOOL)isHighSpeedNetwork{
    CoreNetWorkStatus networkStatus = [self currentNetWorkStatus];
    return networkStatus == CoreNetWorkStatus3G || networkStatus == CoreNetWorkStatus4G || networkStatus == CoreNetWorkStatusWifi;
}

#pragma mark - Private Methods
- (void)setup{
    self.currentRadioAccessTechnology = [CTTelephonyNetworkInfo new].currentRadioAccessTechnology;
    [self.reachability startNotifier];
    [self addNotification];
}

- (CoreNetWorkStatus)statusWithRadioAccessTechnology{
    
    CoreNetWorkStatus status = (CoreNetWorkStatus)[self.reachability currentReachabilityStatus];
    
    NSString *technology = self.currentRadioAccessTechnology;
    if (status == CoreNetWorkStatusWWAN && technology != nil) {
        
        if ([self.technology2GArray containsObject:technology]){
        
            status = CoreNetWorkStatus2G;
            
        }else if ([self.technology3GArray containsObject:technology])
            
            status = CoreNetWorkStatus3G;
        
        else if ([self.technology4GArray containsObject:technology]){
            status = CoreNetWorkStatus4G;
        }
    }
    return status;
}

/**移除监听*/
- (void)removeNotificationObserver{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIApplicationDidBecomeActiveNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CTRadioAccessTechnologyDidChangeNotification object:nil];
}


- (void)addNotification{
    
    //移除旧的监听
    [self removeNotificationObserver];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkDidChangeNoti:) name:kReachabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkDidChangeNoti:) name:CTRadioAccessTechnologyDidChangeNotification object:nil];

 
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becomeActive) name:@"UIApplicationDidBecomeActiveNotification" object:nil];
}

- (void)networkDidChangeNoti:(NSNotification *)noti{

    if ([noti.name isEqualToString:CTRadioAccessTechnologyDidChangeNotification]) {
        self.currentRadioAccessTechnology = noti.object;
    }
    
    NSString *currentNetWorkStatusString = [CoreStatus currentNetWorkStatusString];
    CoreNetWorkStatus currentNetWorkStatus = [CoreStatus currentNetWorkStatus];
    for (id key in self.blockDict) {
        CSStatusDidChangedBlock block = [self.blockDict objectForKey:key];
        block(currentNetWorkStatusString,currentNetWorkStatus);
    }
    
    //兼容旧版本
    //发出通知
    NSDictionary *userInfo = @{@"currentStatusEnum":@(currentNetWorkStatus),@"currentStatusString":currentNetWorkStatusString?:@""};
    [[NSNotificationCenter defaultCenter] postNotificationName:CoreStatusChangedNoti object:self userInfo:userInfo];
}

- (void)becomeActive{
     self.currentRadioAccessTechnology = [CTTelephonyNetworkInfo new].currentRadioAccessTechnology;
}

#pragma mark - Getter
-(Reachability *)reachability{
    
    if(_reachability == nil){
        
        _reachability = [Reachability reachabilityForInternetConnection];
    }
    
    return _reachability;
}

/*
 *  懒加载
 */
- (NSMutableDictionary *)blockDict{
    
    if (nil==_blockDict) {
        _blockDict = [NSMutableDictionary dictionary];
    }
    return _blockDict;
}

/** 2G数组 */
-(NSArray *)technology2GArray{
    
    if(_technology2GArray == nil){
        
        _technology2GArray = @[CTRadioAccessTechnologyEdge,CTRadioAccessTechnologyGPRS];
    }
    
    return _technology2GArray;
}


/** 3G数组 */
-(NSArray *)technology3GArray{
    
    if(_technology3GArray == nil){
        
        _technology3GArray = @[CTRadioAccessTechnologyHSDPA,
                               CTRadioAccessTechnologyWCDMA,
                               CTRadioAccessTechnologyHSUPA,
                               CTRadioAccessTechnologyCDMA1x,
                               CTRadioAccessTechnologyCDMAEVDORev0,
                               CTRadioAccessTechnologyCDMAEVDORevA,
                               CTRadioAccessTechnologyCDMAEVDORevB,
                               CTRadioAccessTechnologyeHRPD];
    }
    
    return _technology3GArray;
}

/** 4G数组 */
-(NSArray *)technology4GArray{
    
    if(_technology4GArray == nil){
        
        _technology4GArray = @[CTRadioAccessTechnologyLTE];
    }
    
    return _technology4GArray;
}

/** 网络状态中文数组 */
-(NSArray *)coreNetworkStatusStringArray{
    
    if(_coreNetworkStatusStringArray == nil){
        
        _coreNetworkStatusStringArray = @[@"无网络",@"Wifi",@"蜂窝网络",@"2G",@"3G",@"4G",@"未知网络"];
    }
    
    return _coreNetworkStatusStringArray;
}
@end

#pragma mark - CoreStatusDeprecated
@implementation CoreStatus (CoreStatusDeprecated)
/** 开始网络监听 */
+(void)beginNotiNetwork:(id<CoreStatusProtocol>)listener{
    
    CoreStatus *status = [CoreStatus sharedCoreStatus];
    
    if(status.isNoti){
        
        NSLog(@"CoreStatus已经处于监听中，请检查其他页面是否关闭监听！");
        
        [self endNotiNetwork:(id<CoreStatusProtocol>)listener];
    }

    
    //注册监听
    [[NSNotificationCenter defaultCenter] addObserver:listener selector:@selector(coreNetworkChangeNoti:) name:CoreStatusChangedNoti object:status];
    [status addNotification];
    
    [status.reachability startNotifier];
    
    //标记
    status.isNoti = YES;
}

/** 停止网络监听 */
+(void)endNotiNetwork:(id<CoreStatusProtocol>)listener{
    
    CoreStatus *status = [CoreStatus sharedCoreStatus];
    
    if(!status.isNoti){
        
        NSLog(@"CoreStatus监听已经被关闭"); return;
    }
    
    //监听
    [[NSNotificationCenter defaultCenter] removeObserver:listener name:CoreStatusChangedNoti object:status];
    [status removeNotificationObserver];
    
    //标记
    status.isNoti = NO;
}
@end
