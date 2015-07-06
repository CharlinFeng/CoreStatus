//
//  CoreCoreNetWorkStatus.h
//  CoreStatus
//
//  Created by 成林 on 15/7/6.
//  Copyright (c) 2015年 muxi. All rights reserved.
//

#ifndef CoreStatus_CoreCoreNetWorkStatus_h
#define CoreStatus_CoreCoreNetWorkStatus_h

/** 网络状态 */
typedef enum{
    
    /** 无网络 */
    CoreNetWorkStatusNone=0,
    
    /** Wifi网络 */
    CoreNetWorkStatusWifi,
    
    /** 蜂窝网络 */
    CoreNetWorkStatusWWAN,
    
    /** 2G网络 */
    CoreNetWorkStatus2G,
    
    /** 3G网络 */
    CoreNetWorkStatus3G,
    
    /** 4G网络 */
    CoreNetWorkStatus4G,
    
    //未知网络
    CoreNetWorkStatusUnkhow
    
}CoreNetWorkStatus;




#endif
