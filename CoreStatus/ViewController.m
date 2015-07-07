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

#define kListenerName   @"可以有很多歌Listener同时监听网络状态的"

@implementation ViewController
- (void)dealloc
{
    [CoreStatus remobeNetworkStatusListener:kListenerName];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString * statusString = [CoreStatus currentNetWorkStatusString];
    
    NSLog(@"%@",statusString);
    
    /** Method deprecated [CoreStatus beginNotiNetwork:self]; */
    self.showLabel.text = [CoreStatus currentNetWorkStatusString];
    [CoreStatus addNetworkStatusListener:kListenerName withDidChangeBlock:^(NSString *statusName, CoreNetWorkStatus status) {
        
        NSLog(@"%@\n",statusName);
        self.showLabel.text = statusName;
        [self.showLabel.layer transitionWithAnimType:TransitionAnimTypeRamdom subType:TransitionSubtypesFromRamdom curve:TransitionCurveRamdom duration:.5f];
    }];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    self.showLabel.text = [CoreStatus currentNetWorkStatusString];
    NSLog(@"%@",[CoreStatus currentNetWorkStatusString]);
}




@end
