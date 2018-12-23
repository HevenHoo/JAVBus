//
//  ActressDetailController.m
//  JAVBus
//
//  Created by mgfjx on 2018/12/16.
//  Copyright © 2018 mgfjx. All rights reserved.
//

#import "ActressDetailController.h"
#import "LJJWaterFlowLayout.h"
#import "MovieListModel.h"
#import "ActressDetailCell.h"
#import "PageCollectionReusableView.h"

#define TitleFont [UIFont systemFontOfSize:14]

@interface ActressDetailController ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) NSArray *dataArray ;
@property (nonatomic, strong) UICollectionView *collectionView ;
@property (nonatomic, assign) NSInteger page ;

@end

@implementation ActressDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.page = 1;
    [self requestData:YES];
    [self createCollectionView];
    [self createBarButton];
    [self.collectionView startHeaderRefreshing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createBarButton {
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 40, 40);
    [button addTarget:self action:@selector(changeSort) forControlEvents:UIControlEventTouchUpInside];
    [button setImage:[UIImage imageNamed:@"sort"] forState:UIControlStateNormal];
    [self.view addSubview:button];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = item;
    
}

//改变列数
- (void)changeSort {
    NSInteger num = [GlobalTool shareInstance].columnNum;
    num = num%3 + 1;
    [GlobalTool shareInstance].columnNum = num;
    LJJWaterFlowLayout *layout = (LJJWaterFlowLayout *)self.collectionView.collectionViewLayout;
    layout.columnNum = [GlobalTool shareInstance].columnNum;
    [self.collectionView reloadData];
}

- (void)requestData:(BOOL)refresh {
    
    if (refresh) {
        self.page = 1;;
    }else{
        self.page ++;
    }
    
    [HTMLTOJSONMANAGER parseActressDetailUrl:self.model.link page:self.page callback:^(NSArray *array) {
        [self.collectionView stopHeaderRefreshing];
        [self.collectionView stopFooterRefreshing];
        
        if (array.count == 0) {
            return ;
        }
        
        NSMutableArray *arr ;
        if (refresh) {
            arr = [NSMutableArray array];
        }else{
            arr = [NSMutableArray arrayWithArray:self.dataArray];
        }
        [arr addObjectsFromArray:array];
        self.dataArray = [arr copy];
        [self.collectionView reloadData];
    }];
    
}

- (void)createCollectionView {
    
    LJJWaterFlowLayout *layout = [[LJJWaterFlowLayout alloc] init];
    layout.columnNum = [GlobalTool shareInstance].columnNum;
//    layout.sectionInset = <#UIEdgeInsets#>;
    
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    UICollectionView *collection = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    collection.delegate = self;
    collection.dataSource = self;
    collection.backgroundColor = [UIColor whiteColor];
    [collection registerNib:[UINib nibWithNibName:NSStringFromClass([ActressDetailCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([ActressDetailCell class])];
    [collection registerNib:[UINib nibWithNibName:NSStringFromClass([PageCollectionReusableView class]) bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([PageCollectionReusableView class])];
    
    [self.view addSubview:collection];
    self.collectionView = collection;
    
    layout.headerReferenceSize = CGSizeMake(MainWidth, 30);
    
    collection.canPullUp = YES;
    collection.headerRefreshBlock = ^(UIScrollView *rfScrollView) {
        [self requestData:YES];
    };
    collection.canPullDown = YES;
    collection.footerRefreshBlock = ^(UIScrollView *rfScrollView) {
        [self requestData:NO];
    };
    
}

#pragma mark - UICollectionViewDelegate,UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ActressDetailCell *cell = (ActressDetailCell *)[collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ActressDetailCell class]) forIndexPath:indexPath];
    MovieListModel *model = self.dataArray[indexPath.row];
    cell.model = model;
    
    LJJWaterFlowLayout *layout = (LJJWaterFlowLayout *)collectionView.collectionViewLayout;
    CGFloat itemWidth = layout.itemWidth;
    
    NSString *name = model.title;
    CGFloat height = [name boundingRectWithSize:CGSizeMake(itemWidth - 2*5, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:TitleFont} context:nil].size.height;
    height = ceilf(height);
    cell.itemHeight = height;
    return cell;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(LJJWaterFlowLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    MovieListModel *model = self.dataArray[indexPath.row];
    CGFloat itemWidth = collectionViewLayout.itemWidth;
    
    NSString *name = model.title;
    CGFloat height = [name boundingRectWithSize:CGSizeMake(itemWidth - 2*5, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:TitleFont} context:nil].size.height;
    
    height = ceilf(height) + 2*5;
    CGFloat itemHeight = 200.0/147*itemWidth + height;
    
    return CGSizeMake(itemWidth, itemHeight);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        PageCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([PageCollectionReusableView class]) forIndexPath:indexPath];
        
        
        reusableview = headerView;
    }
    return reusableview;
}

@end