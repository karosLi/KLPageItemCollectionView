//
//  ViewController.m
//  KLPageItemCollectionView
//
//  Created by karos li on 2018/1/2.
//  Copyright © 2018年 karos. All rights reserved.
//

#import "ViewController.h"
#import "KLPageItemCollectionView.h"

@interface ViewController () <KLPageItemCollectionViewDelegate>

@property (nonatomic, strong) KLPageItemCollectionView *pageItemView1;
@property (nonatomic, strong) KLPageItemCollectionView *pageItemView2;
@property (nonatomic, strong) KLPageItemCollectionView *pageItemView3;

@property (nonatomic, strong) NSArray *data;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.data = @[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", @"13", @"14"];
    
    self.pageItemView1 = [[KLPageItemCollectionView alloc] initWithFrame:self.view.bounds];
    self.pageItemView1.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    self.pageItemView1.colNumInRow = 5;
    self.pageItemView1.itemHeight = 30;
    self.pageItemView1.delegate = self;
    [self.pageItemView1 refreshViewContentSize:self.data.count];
    self.pageItemView1.frame = CGRectMake(0, 64, self.pageItemView1.viewSize.width, self.pageItemView1.viewSize.height);
    [self.pageItemView1 reloadData:self.data.count];
    
    self.pageItemView2 = [[KLPageItemCollectionView alloc] initWithFrame:self.view.bounds];
    self.pageItemView2.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    self.pageItemView2.colNumInRow = 5;
    self.pageItemView2.itemHeight = 30;
    self.pageItemView2.maxRowCountInPage = 2;
    self.pageItemView2.delegate = self;
    [self.pageItemView2 refreshViewContentSize:self.data.count];
    self.pageItemView2.frame = CGRectMake(0, CGRectGetMaxY(self.pageItemView1.frame) + 20, self.pageItemView2.viewSize.width, self.pageItemView2.viewSize.height);
    [self.pageItemView2 reloadData:self.data.count];
    
    self.pageItemView3 = [[KLPageItemCollectionView alloc] initWithFrame:self.view.bounds];
    self.pageItemView3.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    self.pageItemView3.colNumInRow = 5;
    self.pageItemView3.itemHeight = 30;
    self.pageItemView3.maxRowCountInPage = 1;
    self.pageItemView3.delegate = self;
    [self.pageItemView3 refreshViewContentSize:self.data.count];
    self.pageItemView3.frame = CGRectMake(0, CGRectGetMaxY(self.pageItemView2.frame) + 20, self.pageItemView3.viewSize.width, self.pageItemView3.viewSize.height);
    [self.pageItemView3 reloadData:self.data.count];
    
    [self.view addSubview:self.pageItemView1];
    [self.view addSubview:self.pageItemView2];
    [self.view addSubview:self.pageItemView3];
}

- (UIView *)pageItemCollectionView:(KLPageItemCollectionView *)pageItemCollectionView reusedView:(UIView *)reusedView viewForItemAtIndex:(NSInteger)index {
    UILabel *label = (UILabel *)reusedView;
    if (!label) {
        label = [UILabel new];
        label.textAlignment = NSTextAlignmentCenter;
    }
    label.text = self.data[index];
    
    return label;
}

- (void)pageItemCollectionView:(KLPageItemCollectionView *)pageItemCollectionView didSelectView:(UIView *)view forItemAtIndex:(NSInteger)index {
    NSLog(@"tap %@", self.data[index]);
}

@end
