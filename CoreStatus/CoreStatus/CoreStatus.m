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

/** 2G数组 */
@property (nonatomic,strong) NSArray *technology2GArray;

/** 3G数组 */
@property (nonatomic,strong) NSArray *technology3GArray;

/** 4G数组 */
@property (nonatomic,strong) NSArray *technology4GArray;

/** 网络状态中文数组 */
@property (nonatomic,strong) NSArray *coreNetworkStatusStringArray;

@property (nonatomic,strong) Reachability *reachability;

@property (nonatomic,strong) CTTelephonyNetworkInfo *telephonyNetworkInfo;

@property (nonatomic,copy) NSString *currentRaioAccess;

/** 是否正在监听 */
@property (nonatomic,assign) BOOL isNoti;

@end




@implementation CoreStatus
HMSingletonM(CoreStatus)






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

-(Reachability *)reachability{
    
    if(_reachability == nil){
        
        _reachability = [Reachability reachabilityForInternetConnection];
    }
    
    return _reachability;
}


-(CTTelephonyNetworkInfo *)telephonyNetworkInfo{
    
    if(_telephonyNetworkInfo == nil){
        
        _telephonyNetworkInfo = [[CTTelephonyNetworkInfo alloc] init];
        
    }
    
    return _telephonyNetworkInfo;
}


-(NSString *)currentRaioAccess{
    
    if(_currentRaioAccess == nil){
        
        _currentRaioAccess = self.telephonyNetworkInfo.currentRadioAccessTechnology;
    }
    
    return _currentRaioAccess;
}


/** 开始网络监听 */
+(void)beginNotiNetwork:(id<CoreStatusProtocol>)listener{
    
    CoreStatus *status = [CoreStatus sharedCoreStatus];
    
    if(status.isNoti){
    
        NSLog(@"CoreStatus已经处于监听中，请检查其他页面是否关闭监听！");
        
        [self endNotiNetwork:(id<CoreStatusProtocol>)listener];
    }
    
    //注册监听
    [[NSNotificationCenter defaultCenter] addObserver:listener selector:@selector(coreNetworkChangeNoti:) name:CoreStatusChangedNoti object:status];
    [[NSNotificationCenter defaultCenter] addObserver:status selector:@selector(coreNetWorkStatusChanged:) name:kReachabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:status selector:@selector(coreNetWorkStatusChanged:) name:CTRadioAccessTechnologyDidChangeNotification object:nil];

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
    
    //解除监听
    [[NSNotificationCenter defaultCenter] removeObserver:status name:kReachabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:status name:CTRadioAccessTechnologyDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:listener name:CoreStatusChangedNoti object:status];
    
    //标记
    status.isNoti = NO;
    

}







- (void)coreNetWorkStatusChanged:(NSNotification *)notification
{
    //发送通知
    
    if (notification.name == CTRadioAccessTechnologyDidChangeNotification &&
        notification.object != nil) {
        
        self.currentRaioAccess = self.telephonyNetworkInfo.currentRadioAccessTechnology;
    }
    
    //再次发出通知
    NSDictionary *userInfo = @{@"currentStatusEnum":@([CoreStatus currentNetWorkStatus]),@"currentStatusString":[CoreStatus currentNetWorkStatusString]};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CoreStatusChangedNoti object:self userInfo:userInfo];
}





- (CoreNetWorkStatus)statusWithRadioAccessTechnology{
    
    CoreNetWorkStatus status = (CoreNetWorkStatus)[self.reachability currentReachabilityStatus];
    
    NSString *technology = self.currentRaioAccess;
    
    if (status == CoreNetWorkStatusWWAN &&
        technology != nil) {
        
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

/*
 *  懒加载
 */
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
