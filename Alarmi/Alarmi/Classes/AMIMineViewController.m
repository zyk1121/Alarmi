//
//  AMIMineViewController.m
//  Alarmi
//
//  Created by zhangyuanke on 16/2/24.
//  Copyright © 2016年 kdtm. All rights reserved.
//

#import "AMIMineViewController.h"
#import "Masonry.h"
#import <ReactiveCocoa.h>
#import "AudioToolbox/AudioToolbox.h"

@interface AMIMineViewController ()

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, assign) BOOL hasStartFlag;
@property (nonatomic, strong) RACDisposable *timerSignalDisposable;

@end

@implementation AMIMineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"我的";
    self.view.backgroundColor = [UIColor whiteColor];
    _hasStartFlag = NO;
     NSNumber *value = [[NSUserDefaults standardUserDefaults] objectForKey:@"timevalue"];
    
    _label = ({
        UILabel *label = [[UILabel alloc] init];
        label.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
        label.textColor = [UIColor colorWithRed:40/255.0 green:172/255.0 blue:159/255.0 alpha:1];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = [self convertFromTime:value];
        label;
    });
    [self.view addSubview:_label];
    
    _button = ({
        UIButton *button = [[UIButton alloc] init];
        [button setBackgroundImage:[UIImage imageNamed:@"icon_btn_normal.png"] forState:UIControlStateNormal];
        [button setTitle:@"开始" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitle:@"开始" forState:UIControlStateHighlighted];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(buttonClicked) forControlEvents:UIControlEventTouchUpInside];
        button;
    });
    [self.view addSubview:_button];
    [self.view setNeedsUpdateConstraints];
}

- (void)viewWillAppear:(BOOL)animated
{
    NSNumber *value = [[NSUserDefaults standardUserDefaults] objectForKey:@"timevalue"];
    if (!self.hasStartFlag) {
        self.label.text = [self convertFromTime:value];
    }
}

- (void)updateViewConstraints
{
    [super updateViewConstraints];
    
    [self.button mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@100);
        make.center.equalTo(self.view);
    }];
    
    [self.label mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(50);
        make.height.equalTo(@50);
        make.right.equalTo(self.view).offset(-50);
        make.bottom.equalTo(self.button.mas_top).offset(-50);
    }];
}

#pragma mark - private method

- (NSString *)convertFromTime:(NSNumber *)numberValue
{
    NSString *valueString = @"";
    if (numberValue) {
        int value = [numberValue intValue];
        if (value >= 0) {
            int hour = value / 3600;
            int minute = (value - value / 3600 * 3600) / 60;
            int second = (value - value / 3600 * 3600) % 60;
            valueString = [NSString stringWithFormat:@"%02d:%02d:%02d", hour, minute, second];
        }
    }
    return valueString;
}

- (void)buttonClicked
{
    NSNumber *value = [[NSUserDefaults standardUserDefaults] objectForKey:@"timevalue"];
    if (!self.hasStartFlag) {
        if (value && [value intValue] >= 0) {
            self.hasStartFlag = YES;
            [self.button setTitle:@"停止" forState:UIControlStateNormal];
            [self.button setTitle:@"停止" forState:UIControlStateHighlighted];
            [self processTimeCountDown];
        }
    } else {
        [self.timerSignalDisposable dispose];
        self.timerSignalDisposable = nil;
        self.hasStartFlag = NO;
        self.label.text = [self convertFromTime:value];
        [self.button setTitle:@"开始" forState:UIControlStateNormal];
        [self.button setTitle:@"开始" forState:UIControlStateHighlighted];
    }
}

- (void)processTimeCountDown
{
    NSNumber *value = [[NSUserDefaults standardUserDefaults] objectForKey:@"timevalue"];
    if (!value || [value intValue] < 0) {
        return ;
    }
    
    double timeInterval = [value intValue];
    
    __weak AMIMineViewController *weakSelf = self;
    NSDate *expirationDate = [NSDate dateWithTimeInterval:timeInterval sinceDate:[NSDate date]];
    RACSignal *timerSignal = [[[[[RACSignal interval:1 onScheduler:[RACScheduler mainThreadScheduler]]
                                 startWith:NSDate.date]
                                takeUntil:self.rac_willDeallocSignal] map:^id(id value) {
        return @([expirationDate timeIntervalSinceDate:NSDate.date]);
    }] flattenMap:^RACStream *(NSNumber *remainingSeconds) {
        if ([remainingSeconds doubleValue] < 1) {
            return [RACSignal error:nil];
        } else {
            return [RACSignal return:remainingSeconds];
        }
    }];
    
    self.timerSignalDisposable = [timerSignal subscribeNext:^(NSNumber *remainingSeconds) {
        weakSelf.label.text = [NSString stringWithFormat:@"系统将在%@后提醒", [weakSelf convertFromTime:remainingSeconds]];
    } error:^(NSError *error) {
        weakSelf.label.text = @"系统正在震动提醒";
        [weakSelf processForTimeout];
    }];
}

- (void)processForTimeout
{
    if (self.hasStartFlag) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (self.hasStartFlag) {
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                [self processForTimeout];
            }
        });
    }
}

@end
