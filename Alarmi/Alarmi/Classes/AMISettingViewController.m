//
//  AMISettingViewController.m
//  Alarmi
//
//  Created by zhangyuanke on 16/2/24.
//  Copyright © 2016年 kdtm. All rights reserved.
//

#import "AMISettingViewController.h"
#import "Masonry.h"

@interface AMISettingViewController () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) NSArray *array;
@property (nonatomic, strong) NSMutableArray *hourArray;
@property (nonatomic, strong) NSMutableArray *minuteArray;
@property (nonatomic, strong) NSMutableArray *secondArray;

@end

@implementation AMISettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"设置";
    self.view.backgroundColor = [UIColor whiteColor];
    
    _pickerView = ({
        UIPickerView *pickView = [[UIPickerView alloc] init];
        pickView.delegate = self;
        pickView.dataSource = self;
        pickView;
    });
    [self.view addSubview:_pickerView];
    
    _hourArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < 24; i++) {
        [_hourArray addObject:@(i)];
    }
    
    _minuteArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < 60; i++) {
        [_minuteArray addObject:@(i)];
    }
    
    _secondArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < 60; i++) {
        [_secondArray addObject:@(i)];
    }
    
    _array = [NSArray arrayWithObjects:_hourArray, _minuteArray, _secondArray, nil];
    
    [self setPickViewData];
    
    [self.view setNeedsUpdateConstraints];
}

- (void)updateViewConstraints
{
    [super updateViewConstraints];
    
    [self.pickerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.center.equalTo(self.view);
    }];
}

#pragma mark - delegate

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return [self.array count];
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.array[component] count];
}

-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *retStr;
    switch (component) {
        case 0:
            retStr = [NSString stringWithFormat:@"%ld小时", [(NSNumber *)[self.array[component] objectAtIndex:row] integerValue]];
            break;
        case 1:
            retStr = [NSString stringWithFormat:@"%ld分", [(NSNumber *)[self.array[component] objectAtIndex:row] integerValue]];
            break;
        case 2:
            retStr = [NSString stringWithFormat:@"%ld秒", [(NSNumber *)[self.array[component] objectAtIndex:row] integerValue]];
            break;
        default:
            break;
    }
    return retStr;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSUInteger number = 0;
    NSUInteger rowHour = [pickerView selectedRowInComponent:0];
    NSUInteger rowMinute = [pickerView selectedRowInComponent:1];
    NSUInteger rowSecond = [pickerView selectedRowInComponent:2];
    number = rowHour * 3600 + rowMinute * 60 + rowSecond;
    
    NSNumber *num = [NSNumber numberWithInteger:number];
    [[NSUserDefaults standardUserDefaults] setObject:num forKey:@"timevalue"];
    
}

#pragma mark - private method

- (void)setPickViewData
{
    NSNumber *numberValue = [[NSUserDefaults standardUserDefaults] objectForKey:@"timevalue"];
    if (!numberValue || [numberValue intValue] < 0) {
        return;
    }
    
    int value = [numberValue intValue];
    if (value >= 0) {
        int hour = value / 3600;
        int minute = (value - value / 3600 * 3600) / 60;
        int second = (value - value / 3600 * 3600) % 60;
        
        [self.pickerView selectRow:hour inComponent:0 animated:YES];
        [self.pickerView selectRow:minute inComponent:1 animated:YES];
        [self.pickerView selectRow:second inComponent:2 animated:YES];
    }
}


@end
