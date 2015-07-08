//
//  ViewController.m
//  CoreStatus
//
//  Created by muxi on 15/3/24.
//  Copyright (c) 2015年 muxi. All rights reserved.
//

#import "ViewController.h"
#import "CoreStatus.h"
#import "CALayer+Transition.h"


@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *showLabel;

@end

#define kListenerName_1   @"kListenerName_1"
#define kListenerName_2   @"kListenerName_2"

@implementation ViewController
- (void)dealloc
{
    [CoreStatus removeNetworkStatusListener:kListenerName_1];
    [CoreStatus removeNetworkStatusListener:kListenerName_2];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString * statusString = [CoreStatus currentNetWorkStatusString];
    
    NSLog(@"currentNetWorkStatusString :%@",statusString);
    
    /** Method deprecated [CoreStatus beginNotiNetwork:self]; */
    
    //可以有很多个Listener同时监听网络状态的
    [CoreStatus addNetworkStatusListener:kListenerName_1 withDidChangeBlock:^(NSString *statusName, CoreNetWorkStatus status) {
        NSLog(@"block 1 invoke");
    }];
    
    __weak ViewController *ws = self;
    [CoreStatus addNetworkStatusListener:kListenerName_1 withDidChangeBlock:^(NSString *statusName, CoreNetWorkStatus status) {
        NSLog(@"block 2 invoke");
        
        NSLog(@"%@\n",statusName);
        ws.showLabel.text = statusName;
        [ws.showLabel.layer transitionWithAnimType:TransitionAnimTypeReveal subType:TransitionSubtypesFromTop curve:TransitionCurveEaseInEaseOut duration:.5f];
    }];
    
    [CoreStatus addNetworkStatusListener:kListenerName_2 withDidChangeBlock:^(NSString *statusName, CoreNetWorkStatus status) {
        NSLog(@"block 3 invoke");
    }];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    self.showLabel.text = [CoreStatus currentNetWorkStatusString];
    NSLog(@"%@",[CoreStatus currentNetWorkStatusString]);
}




@end
