//
//  YLWaterFallView.h
//  WaterFallDemo
//
//  Created by 杨立 on 15/10/21.
//  Copyright (c) 2015年 杨立. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, YLWaterFallViewMarginType) {
    YLWaterFallViewMarginTypeTop,
    YLWaterFallViewMarginTypeBottom,
    YLWaterFallViewMarginTypeLeft,
    YLWaterFallViewMarginTypeRight,
    YLWaterFallViewMarginTypeColumns,
    YLWaterFallViewMarginTypeRows
};

@class YLWaterFallCell, YLWaterFallView;

/**
 *  数据源
 */
@protocol YLWaterFallViewDataSource <NSObject>

/**
 *  返回index所在位置的cell
 */
-(YLWaterFallCell *)waterFallView:(YLWaterFallView *)waterFallView cellForIndex:(NSUInteger)index;

/**
 *  返回一共有多少个cell
 */
-(NSUInteger)numbersOfCellsInWaterFallView:(YLWaterFallView *)waterFallView;

@optional
/**
 *  返回有多少列
 */
-(NSUInteger)numbersOfColumnsInWaterFallView:(YLWaterFallView *)waterFallView;
@end

/**
 * 代理
 */
@protocol YLWaterFallViewDelegate <NSObject>

@optional
/**
 *  返回index位置cell的高度
 */
-(CGFloat)waterFallView:(YLWaterFallView *)waterFallView heightForCellAtIndex:(NSUInteger)index;

/**
 *  返回间距
 */
-(CGFloat)waterFallView:(YLWaterFallView *)waterFallView marginForType:(YLWaterFallViewMarginType)type;

/**
 *  处理选中事件
 */
-(void)waterFallView:(YLWaterFallView *)waterFallView didSelectedAtIndex:(NSUInteger)index;

@end
@interface YLWaterFallView : UIScrollView

@property (nonatomic, weak) id<YLWaterFallViewDataSource> datasource;
@property (nonatomic, weak) id<YLWaterFallViewDelegate> delegate;

/**
 *  刷新数据
 */
-(void)reloadData;
/**
 *  得到缓存池的cell
 */
-(id)dequeueReusableCellWithIdentifier:(NSString *)identifier;

@end
