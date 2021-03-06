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

@property (nonatomic, assign, readonly) CGSize viewSize; // 整个视图的宽高，可以在调用 calculateViewSize 方法后获取
@property (nonatomic, assign, readonly) BOOL pageEnabled; // 是否是分页模式，可以在调用 calculateViewSize 方法后获取

@property (nonatomic, assign) CGFloat itemHeight; //item 的高度，默认 50
@property (nonatomic, assign) UIEdgeInsets sectionInset; //每页视图内边距大小，默认每一页边距都是 UIEdgeInsetsMake(20, 20, 20, 20), pageControl 在 section.bottom 垂直居中对齐
@property (nonatomic, assign) CGFloat lineSpacing; //行间距，默认 15
@property (nonatomic, assign) CGFloat interitemSpacing; //列边距，默认 0
@property (nonatomic, assign) NSInteger colNumInRow; //一行的列数，默认 1
@property (nonatomic, assign) NSInteger maxRowCountInPage;  //一页的最大行数；如果大于0，需要按最大行数分页；如果等于0，需要显示所有行数，不分页；默认有几行显示几行

@property (nonatomic, strong, nullable) UIColor *pageIndicatorTintColor; //分页指示器背景色
@property (nonatomic, strong, nullable) UIColor *currentPageIndicatorTintColor; //分页指示器当前页颜色

@property (nonatomic, weak, nullable) id<KLPageItemCollectionViewDelegate> delegate;

// 计算视图大小，一般用于在获取到数据之后，提前计算视图大小
- (void)calculateViewSize:(NSInteger)totalItemsCount;

// 刷新数据
- (void)reloadData:(NSInteger)totalItemsCount;

@end
