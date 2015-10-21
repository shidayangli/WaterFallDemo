//
//  YLWaterFallViewController.m
//  WaterFallDemo
//
//  Created by 杨立 on 15/10/21.
//  Copyright (c) 2015年 杨立. All rights reserved.
//

#import "YLWaterFallViewController.h"
#import "YLWaterFallView.h"
#import "YLWaterFallCell.h"

#define YLColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]
#define YLRandomColor YLColor(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256))

@interface YLWaterFallViewController ()<YLWaterFallViewDelegate, YLWaterFallViewDataSource>

@end

@implementation YLWaterFallViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    YLWaterFallView *waterFallView = [[YLWaterFallView alloc] init];
    waterFallView.frame = self.view.bounds;
    waterFallView.datasource = self;
    waterFallView.delegate = self;
    [self.view addSubview:waterFallView];
    [waterFallView reloadData];
}

#pragma mark - YLWaterFallViewDelegate method

-(CGFloat)waterFallView:(YLWaterFallView *)waterFallView heightForCellAtIndex:(NSUInteger)index
{
    switch (index % 3) {
        case 0:
            return 150;
        case 1:
            return 110;
        case 2:
            return 200;
        default:
            return 100;
    }
}

-(CGFloat)waterFallView:(YLWaterFallView *)waterFallView marginForType:(YLWaterFallViewMarginType)type
{
    switch (type) {
        case YLWaterFallViewMarginTypeBottom:
        case YLWaterFallViewMarginTypeLeft:
        case YLWaterFallViewMarginTypeRight:
        case YLWaterFallViewMarginTypeTop:
            return 10;
            break;
        case YLWaterFallViewMarginTypeColumns:
            return 12;
            break;
        case YLWaterFallViewMarginTypeRows:
            return 15;
            break;
        default:
            return 11;
            break;
    }
}

-(void)waterFallView:(YLWaterFallView *)waterFallView didSelectedAtIndex:(NSUInteger)index
{
    NSLog(@"点击了第%ld个", index);
}

#pragma mark - YLWaterFallViewDataSource method

-(YLWaterFallCell *)waterFallView:(YLWaterFallView *)waterFallView cellForIndex:(NSUInteger)index
{
    YLWaterFallCell *cell = [waterFallView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[YLWaterFallCell alloc] init];
        cell.identifier = @"cell";
    }
    cell.backgroundColor = YLRandomColor;
    return cell;
}

-(NSUInteger)numbersOfCellsInWaterFallView:(YLWaterFallView *)waterFallView
{
    return 100;
}

-(NSUInteger)numbersOfColumnsInWaterFallView:(YLWaterFallView *)waterFallView
{
    return 4;
}


@end
