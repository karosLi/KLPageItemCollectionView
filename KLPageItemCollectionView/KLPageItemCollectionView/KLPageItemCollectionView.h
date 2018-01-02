//
//  KLPageItemCollectionView.h
//  KLPageItemCollectionView
//
//  Created by karos li on 2018/1/2.
//  Copyright © 2018年 karos. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KLPageItemCollectionView;
@protocol KLPageItemCollectionViewDelegate <NSObject>

@required
// 需要代理类每次返回新的视图对象
- (nonnull UIView *)pageItemCollectionView:(nonnull KLPageItemCollectionView *)pageItemCollectionView reusedView:(nullable UIView *)reusedView viewForItemAtIndex:(NSInteger)index;

@optional
// 当点击视图时，通知代理类点击视图的位置
- (void)pageItemCollectionView:(nonnull KLPageItemCollectionView *)pageItemCollectionView didSelectView:(nonnull UIView *)view forItemAtIndex:(NSInteger)index;

@end

@interface KLPageItemCollectionView : UIView

@property (nonatomic, assign, readonly) CGSize viewSize; // 整个视图的宽高

@property (nonatomic, assign) CGFloat itemHeight; //item 的高度，默认 50
@property (nonatomic, assign) UIEdgeInsets sectionInset; //每页视图内边距大小，默认每一页边距都是 UIEdgeInsetsMake(20, 20, 20, 20)
@property (nonatomic, assign) CGFloat lineSpacing; //行间距，默认 15
@property (nonatomic, assign) CGFloat interitemSpacing; //列边距，默认 0
@property (nonatomic, assign) NSInteger colNumInRow; //一行的列数，默认 1
@property (nonatomic, assign) NSInteger maxRowCountInPage; //一页的最大行数，默认有几行显示几行

@property(nonatomic, strong) UIColor *pageIndicatorTintColor; //分页指示器背景色
@property(nonatomic, strong) UIColor *currentPageIndicatorTintColor; //分页指示器当前页颜色

@property (nonatomic, weak, nullable) id<KLPageItemCollectionViewDelegate> delegate;

// 计算 view content size
- (void)refreshViewContentSize:(NSInteger)totalItemsCount;

// 刷新数据
- (void)reloadData:(NSInteger)totalItemsCount;

@end
