//
//  KLPageItemCollectionView.m
//  KLPageItemCollectionView
//
//  Created by karos li on 2018/1/2.
//  Copyright © 2018年 karos. All rights reserved.
//

#import "KLPageItemCollectionView.h"

@interface KLPageItemCollectionViewFlowLayout : UICollectionViewLayout

@property (nonatomic, assign) CGFloat itemHeight; //item 的高度
@property (nonatomic, assign) UIEdgeInsets sectionInset; //每页视图内边距大小
@property (nonatomic, assign) CGFloat lineSpacing; //行间距
@property (nonatomic, assign) CGFloat interitemSpacing; //列边距
@property (nonatomic, assign) NSInteger colNumInRow; //一行的列数
@property (nonatomic, assign) NSInteger maxRowCountInPage; //一页的最大行数，默认有几行显示几行

@property (nonatomic, assign, readonly) NSInteger totalPage; //总页数
@property (nonatomic, strong, readonly) NSMutableArray *allItemAttributes; //所有的item的布局信息

@end

@interface KLPageItemCollectionViewFlowLayout()

/// Array to store height for each column
@property (nonatomic, strong) NSMutableArray *columnHeights;
/// Array to store attributes for all items includes headers, cells, and footers
@property (nonatomic, strong) NSMutableArray *allItemAttributes;
/// Total Page
@property (nonatomic, assign) NSInteger totalPage;
/// Page enabled
@property (nonatomic, assign) BOOL pageEnabled;
/// Content size
@property (nonatomic, assign) CGSize contentSize;

@end

@implementation KLPageItemCollectionViewFlowLayout

- (id)init {
    if (self = [super init]) {
        [self initConfiguration];
    }
    
    return self;
}

- (void)initConfiguration {
    self.columnHeights = [NSMutableArray array];
    self.allItemAttributes = [NSMutableArray array];
}

- (void)prepareLayout {
    [super prepareLayout];
    
    [self.columnHeights removeAllObjects];
    [self.allItemAttributes removeAllObjects];
    self.pageEnabled = NO;
    
    if (self.colNumInRow <= 0) {
        self.colNumInRow = 1;
    }
    
    if (self.maxRowCountInPage < 0) {
        self.maxRowCountInPage = 0;
    }
    
    NSInteger numberOfSections = [self.collectionView numberOfSections];
    if (numberOfSections == 0) {
        return;
    }
    
    NSInteger idx;
    for (idx = 0; idx < self.colNumInRow; idx++) {
        self.columnHeights[idx] = @(self.sectionInset.top);
    }
    
    NSInteger itemCount = [self.collectionView numberOfItemsInSection:0];
    NSInteger itemCountInPage = self.maxRowCountInPage * self.colNumInRow;
    if (self.maxRowCountInPage > 0) {
        self.totalPage = itemCount % itemCountInPage == 0 ? itemCount / itemCountInPage : itemCount / itemCountInPage + 1;
        self.pageEnabled = self.totalPage > 1;
    }
    
    CGFloat viewWidth = self.collectionView.frame.size.width;
    CGFloat itemWidth = (viewWidth - self.sectionInset.left - self.sectionInset.right - (self.colNumInRow - 1) * self.interitemSpacing) / self.colNumInRow;
    CGFloat itemHeight = self.itemHeight;
    // 如果分页，一页的高度
    CGFloat pageHeight = self.sectionInset.top + self.sectionInset.bottom + (itemHeight + self.lineSpacing) * self.maxRowCountInPage - self.lineSpacing;
    
    for (idx = 0; idx < itemCount; idx++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:idx inSection:0];
        NSInteger rowIndex = 0;
        NSInteger pageIndex = 0;
        if (self.pageEnabled) {
            pageIndex = idx / itemCountInPage;
            rowIndex = (idx - pageIndex * itemCountInPage) / self.colNumInRow;
        }
        
        NSInteger colIndex = idx % self.colNumInRow;
        CGFloat x;
        CGFloat y;
        x = pageIndex * viewWidth + self.sectionInset.left + (itemWidth + self.interitemSpacing) * colIndex;
        
        if (self.pageEnabled && rowIndex == 0) {  // 如果分页并当前行是第一行，y 需要重新计算
            y = self.sectionInset.top;
        } else {
            y = [self.columnHeights[colIndex] floatValue];
        }
        
        // 创建属性
        UICollectionViewLayoutAttributes *attrs = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        attrs.frame = CGRectMake(x, y, itemWidth, itemHeight);
        self.columnHeights[colIndex] = @(CGRectGetMaxY(attrs.frame) + self.lineSpacing);
        [self.allItemAttributes addObject:attrs];
    }
    
    if (self.pageEnabled) {
        self.contentSize = CGSizeMake(self.totalPage * viewWidth, pageHeight);
    } else {
        self.contentSize = CGSizeMake(viewWidth, [self.columnHeights[0] floatValue] - self.lineSpacing + self.sectionInset.bottom);
    }
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    return self.allItemAttributes;
}

- (CGSize)collectionViewContentSize {
    return self.contentSize;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    CGRect oldBounds = self.collectionView.bounds;
    if (CGRectGetWidth(newBounds) != CGRectGetWidth(oldBounds)) {
        return YES;
    }
    return NO;
}

@end

@interface KLPageItemDynamicCollectionView : UICollectionView

@property (nonatomic, assign) CGSize viewContentSize;

@end

@implementation KLPageItemDynamicCollectionView

- (CGSize)intrinsicContentSize {
    return self.viewContentSize;
}

@end

@interface KLPageItemCollectionView() <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) KLPageItemDynamicCollectionView *collectionView;

@property (nonatomic, assign) NSInteger totalItemsCount; // 总数据个数
@property (nonatomic, strong) KLPageItemCollectionViewFlowLayout *flowLayout;

@property (nonatomic, strong) UIPageControl *pageControl;

@end

@implementation KLPageItemCollectionView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    self.itemHeight = 50;
    self.sectionInset = UIEdgeInsetsMake(20, 20, 20, 20);
    self.interitemSpacing = CGFLOAT_MIN;
    self.lineSpacing = 15;
    self.colNumInRow = 1;
    
    [self addSubview:self.collectionView];
    [self addSubview:self.pageControl];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class])];
    
    return self;
}

- (void)layoutSubviews {
    // 确保 contentsize 计算正确
    [self calculateViewSize];
    
    [super layoutSubviews];
    self.collectionView.frame = self.bounds;
    self.pageControl.frame = CGRectMake(0, CGRectGetHeight(self.bounds) - 6 - 8, CGRectGetWidth(self.bounds), 8);
}

#pragma mark - public methods
- (void)reloadData:(NSInteger)totalItemsCount {
    self.totalItemsCount = totalItemsCount;
    
    [self calculateViewSize];
    [self.collectionView reloadData];
}

- (void)calculateViewSize:(NSInteger)totalItemsCount {
    self.colNumInRow = MAX(1, self.colNumInRow);
    self.maxRowCountInPage = MAX(0, self.maxRowCountInPage);
    self.flowLayout.colNumInRow = self.colNumInRow;
    self.flowLayout.interitemSpacing = self.interitemSpacing;
    self.flowLayout.lineSpacing = self.lineSpacing;
    self.flowLayout.sectionInset = self.sectionInset;
    self.flowLayout.itemHeight = self.itemHeight;
    self.flowLayout.maxRowCountInPage = self.maxRowCountInPage;
    
    BOOL pageEnabled = NO;
    NSInteger totalPage = 0;
    NSInteger itemCount = totalItemsCount;
    NSInteger itemCountInPage = self.maxRowCountInPage * self.colNumInRow;
    if (self.maxRowCountInPage > 0) {
        totalPage = itemCount % itemCountInPage == 0 ? itemCount / itemCountInPage : itemCount / itemCountInPage + 1;
        pageEnabled = totalPage > 1;
    }
    
    CGFloat viewWidth = CGRectGetWidth(self.bounds);
    CGFloat itemHeight = self.itemHeight;
    // 如果分页，一页的高度
    CGFloat pageHeight = self.sectionInset.top + self.sectionInset.bottom + (itemHeight + self.lineSpacing) * self.maxRowCountInPage - self.lineSpacing;
    
    if (pageEnabled) {
        self.pageControl.hidden = NO;
        self.pageControl.numberOfPages = totalPage;
        self.collectionView.viewContentSize = CGSizeMake(viewWidth, pageHeight);
    } else {
        self.pageControl.hidden = YES;
        self.pageControl.numberOfPages = 0;
        self.collectionView.viewContentSize = CGSizeMake(viewWidth, self.sectionInset.top + self.sectionInset.bottom + (itemHeight + self.lineSpacing) * (itemCount % self.colNumInRow == 0 ? itemCount / self.colNumInRow : (NSInteger)(itemCount / self.colNumInRow) + 1) - self.lineSpacing);
    }
}

- (CGSize)viewSize {
    return self.collectionView.viewContentSize;
}

- (void)setPageIndicatorTintColor:(UIColor *)pageIndicatorTintColor {
    self.pageControl.pageIndicatorTintColor = pageIndicatorTintColor;
}

- (void)setCurrentPageIndicatorTintColor:(UIColor *)currentPageIndicatorTintColor {
    self.pageControl.currentPageIndicatorTintColor = currentPageIndicatorTintColor;
}

#pragma mark - private methods
- (void)calculateViewSize {
    [self calculateViewSize:self.totalItemsCount];
}

#pragma mark - UICollectionViewDelegate & UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.totalItemsCount;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class]) forIndexPath:indexPath];
    
    UIView *view;
    UIView *reusedView = cell.contentView.subviews.firstObject;
    if ([self.delegate respondsToSelector:@selector(pageItemCollectionView:reusedView:viewForItemAtIndex:)]) {
        view = [self.delegate pageItemCollectionView:self reusedView:reusedView viewForItemAtIndex:indexPath.item];
    }
    
    if (view) {
        if (!view.superview) {
            [cell.contentView addSubview:view];
        }
        
        view.frame = cell.contentView.bounds;
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    if ([self.delegate respondsToSelector:@selector(pageItemCollectionView:didSelectView:forItemAtIndex:)]) {
        [self.delegate pageItemCollectionView:self didSelectView:cell.subviews.firstObject forItemAtIndex:indexPath.item];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetX = scrollView.contentOffset.x;
    CGFloat width = CGRectGetWidth(scrollView.bounds);
    
    NSInteger page = ceil(offsetX / width);
    self.pageControl.currentPage = page;
}

#pragma mark - getter
- (KLPageItemCollectionViewFlowLayout *)flowLayout {
    if (!_flowLayout) {
        _flowLayout = [KLPageItemCollectionViewFlowLayout new];
    }
    return _flowLayout;
}

- (UIPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [UIPageControl new];
        _pageControl.pageIndicatorTintColor = [[UIColor orangeColor] colorWithAlphaComponent:0.3];
        _pageControl.currentPageIndicatorTintColor = [UIColor orangeColor];
    }
    
    return _pageControl;
}

- (KLPageItemDynamicCollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[KLPageItemDynamicCollectionView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) collectionViewLayout:self.flowLayout];
        [_collectionView setBackgroundColor:[UIColor clearColor]];
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.clipsToBounds = YES;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.pagingEnabled = YES;
        _collectionView.alwaysBounceVertical = NO;
    }
    
    return _collectionView;
}

@end
