//
//  ViewController.m
//  CoreStatus
//
//  Created by muxi on 15/3/24.
//  Copyright (c) 2015年 muxi. All rights reserved.
//

#import "ViewController.h"
#import "CoreStatus.h"


@interface ViewController ()<CoreStatusProtocol>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [CoreStatus beginNotiNetwork:self];
    
}




-(void)coreNetworkChangeNoti:(NSNotification *)noti{
    
    NSString * statusString = [CoreStatus currentNetWorkStatusString];
    
    NSLog(@"%@",statusString);
    
}




@end
