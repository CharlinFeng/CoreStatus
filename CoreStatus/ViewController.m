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


@interface ViewController ()<CoreStatusProtocol>

@property (weak, nonatomic) IBOutlet UILabel *showLabel;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString * statusString = [CoreStatus currentNetWorkStatusString];
    
    NSLog(@"%@",statusString);
    
    [CoreStatus beginNotiNetwork:self];
    
}




-(void)coreNetworkChangeNoti:(NSNotification *)noti{
    
    NSString * statusString = [CoreStatus currentNetWorkStatusString];
    
    NSLog(@"%@\n\n\n\n=========================\n\n\n\n%@",noti,statusString);
    
    self.showLabel.text = statusString;
    [self.showLabel.layer transitionWithAnimType:TransitionAnimTypeRamdom subType:TransitionSubtypesFromRamdom curve:TransitionCurveRamdom duration:.5f];
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSString * statusString = [CoreStatus currentNetWorkStatusString];
    
    NSLog(@"%@",statusString);
}




@end
