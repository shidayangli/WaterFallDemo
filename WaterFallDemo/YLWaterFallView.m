//
//  YLWaterFallView.m
//  WaterFallDemo
//
//  Created by 杨立 on 15/10/21.
//  Copyright (c) 2015年 杨立. All rights reserved.
//

#import "YLWaterFallView.h"
#import "YLWaterFallCell.h"

@interface YLWaterFallView ()
/**
 *  存放frame的数组
 */
@property (nonatomic, strong) NSMutableArray *frameArray;

/**
 *  存放显示在屏幕上的cell，用字典
 */
@property (nonatomic, strong) NSMutableDictionary *cellsOnScreen;

/**
 *  缓存池
 */
@property (nonatomic, strong) NSMutableSet *reusableCells;
@end

@implementation YLWaterFallView

-(NSMutableArray *)frameArray
{
    if (!_frameArray) {
        _frameArray = [NSMutableArray array];
    }
    return _frameArray;
}

-(NSMutableDictionary *)cellsOnScreen
{
    if (!_cellsOnScreen) {
        _cellsOnScreen = [NSMutableDictionary dictionary];
    }
    return _cellsOnScreen;
}

-(NSMutableSet *)reusableCells
{
    if (!_reusableCells) {
        _reusableCells = [NSMutableSet set];
    }
    return _reusableCells;
}

#pragma mark - public API

-(void)reloadData
{
    //计算cell的frame
    //1.cell的总数
    NSUInteger numberOfCells = [self.datasource numbersOfCellsInWaterFallView:self];
    //2.cell的总列数
    NSUInteger numberOfColumns = [self numberOfColumns];
    
    //3.cell的间距
    CGFloat top = [self marginForType:YLWaterFallViewMarginTypeTop];
    CGFloat bottom = [self marginForType:YLWaterFallViewMarginTypeBottom];
    CGFloat left = [self marginForType:YLWaterFallViewMarginTypeLeft];
    CGFloat right = [self marginForType:YLWaterFallViewMarginTypeRight];
    CGFloat column = [self marginForType:YLWaterFallViewMarginTypeColumns];
    CGFloat row = [self marginForType:YLWaterFallViewMarginTypeRows];
    
    //4.cell的宽度
    CGFloat cellW = (self.bounds.size.width - left - right - (numberOfColumns - 1) * column) / numberOfColumns;
    
    //5.计算cell的frame
    //先用一个c类型数组存起每一列的最大值
    CGFloat maxYOfColumns[numberOfColumns];
    for (NSUInteger i = 0; i < numberOfColumns; i++) {
        maxYOfColumns[i] = 0.0;
    }
    //计算每一个cell所在的位置，这里的原则是依次遍历每一列的y值，取最小的一列放置最新的cell，这样才能达到瀑布流的效果
    for (NSUInteger i = 0; i < numberOfCells; i++) {
        //从第0列开始一个一个对比，有比它的y值小的就取出来，直到所有列数遍历完剩下的就是最小值，一个很基础的算法
        NSUInteger theColumn = 0;
        CGFloat yOfTheColumn = maxYOfColumns[theColumn];
        for (NSUInteger j = 0; j < numberOfColumns; j++) {
            if (maxYOfColumns[j] < yOfTheColumn) {
                theColumn = j;
                yOfTheColumn = maxYOfColumns[j];
            }
        }
        //取出该cell的高度
        CGFloat cellH = [self heightAtIndex:i];
        //x值
        CGFloat cellX = left + theColumn * (cellW + column);
        //y值
        CGFloat cellY;
        if (yOfTheColumn == 0) {
            cellY = top;
        }else{
            cellY = yOfTheColumn + row;
        }
        CGRect cellFrame = CGRectMake(cellX, cellY, cellW, cellH);
        //添加到frame数组中
        [self.frameArray addObject:[NSValue valueWithCGRect:cellFrame]];
        
        //更新这一列的y值
        maxYOfColumns[theColumn] = CGRectGetMaxY(cellFrame);
    }
    //设置contentsize
    CGFloat contentH = maxYOfColumns[0];
    for (NSUInteger i = 0; i < numberOfColumns; i++) {
        if (contentH < maxYOfColumns[i]) {
            contentH = maxYOfColumns[i];
        }
    }
    contentH += bottom;
    self.contentSize = CGSizeMake(0, contentH);
}

-(void)layoutSubviews
{
    for (NSUInteger i = 0; i < self.frameArray.count; i++) {
        //取出frame
        CGRect cellFrame = [self.frameArray[i] CGRectValue];
        //先从屏幕显示cell的数组中取出
        YLWaterFallCell *cell = self.cellsOnScreen[@(i)];
        if ([self cellIsOnScreen:cellFrame]) {
            if (cell == nil) {
                cell = [self.datasource waterFallView:self cellForIndex:i];
                cell.frame = cellFrame;
                self.cellsOnScreen[@(i)] = cell;
                [self addSubview:cell];
            }
        }else{
            if (cell) {
                [cell removeFromSuperview];
                [self.cellsOnScreen removeObjectForKey:@(i)];
                
                //放入缓存池
                [self.reusableCells addObject:cell];
            }
        }
    }
}

-(id)dequeueReusableCellWithIdentifier:(NSString *)identifier
{
    __block YLWaterFallCell *resuableCell = nil;
    [self.reusableCells enumerateObjectsUsingBlock:^(YLWaterFallCell *cell, BOOL *stop) {
        if ([cell.identifier isEqualToString:identifier]) {
            resuableCell = cell;
            *stop = YES;
        }
    }];
    if (resuableCell) {
        [self.reusableCells removeObject:resuableCell];
    }
    return resuableCell;
}

#pragma mark - private method
/**
 *  判断cell是否在屏幕上
 */
-(BOOL)cellIsOnScreen:(CGRect)frame
{
    return (CGRectGetMaxY(frame) > self.contentOffset.y) && (CGRectGetMinY(frame) < self.frame.size.height + self.contentOffset.y);
}
/**
 *  返回index位置的高度
 */
-(CGFloat)heightAtIndex:(NSUInteger)index
{
    if ([self.delegate respondsToSelector:@selector(waterFallView:heightForCellAtIndex:)]) {
        return [self.delegate waterFallView:self heightForCellAtIndex:index];
    }else{
        return 33;
    }
}

/**
 *  返回列数
 */
-(NSUInteger)numberOfColumns
{
    if ([self.datasource respondsToSelector:@selector(numbersOfColumnsInWaterFallView:)]) {
        return [self.datasource numbersOfColumnsInWaterFallView:self];
    }else{
        return 3;
    }
}

/**
 *  返回间距
 */
-(CGFloat)marginForType:(YLWaterFallViewMarginType)type
{
    if ([self.delegate respondsToSelector:@selector(waterFallView:marginForType:)]) {
        return [self.delegate waterFallView:self marginForType:type];
    }else{
        return 10;
    }
}

/**
 *  处理触摸事件
 */
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (![self.delegate respondsToSelector:@selector(waterFallView:didSelectedAtIndex:)]) return;
    
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    
    __block NSUInteger selectedCellIndex = 0;
    [self.cellsOnScreen enumerateKeysAndObjectsUsingBlock:^(NSNumber *index, YLWaterFallCell *cell, BOOL *stop) {
        if (CGRectContainsPoint(cell.frame, touchPoint)) {
            selectedCellIndex = index.unsignedIntegerValue;
            *stop = YES;
        }
    }];
    if (selectedCellIndex) {
        [self.delegate waterFallView:self didSelectedAtIndex:selectedCellIndex];
    }
}
@end
