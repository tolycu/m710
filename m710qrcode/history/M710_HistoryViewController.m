//
//  M710_HistoryViewController.m
//  m710qrcode
//
//  Created by xc-76 on 2022/4/21.
//

#import "M710_HistoryViewController.h"
#import "M710_ScanResultController.h"
#import "M710_CreatResultController.h"

#import "HistoryCellView.h"
#import "SelectNavgidueView.h"


@interface M710_HistoryViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic ,strong) UITableView *tableView;
@property (nonatomic ,strong) NSMutableArray *dataList;

@property (nonatomic ,assign) NSInteger index;
@end

@implementation M710_HistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addSubView_layout];
    [self reloadDataList];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HistoryCellView *cell = [tableView dequeueReusableCellWithIdentifier:@"HistoryCellView" forIndexPath:indexPath];
    cell.dataDict = self.dataList[indexPath.section];
    cell.deleteBlock = ^{
        [self deleteHistoryAtIndexPath:indexPath];
    };
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 5.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footerView = [[UIView alloc] init];
    footerView.backgroundColor = [UIColor colorWithString:@"#FAFAFA"];
    return footerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *resultStr = self.dataList[indexPath.section][@"resultStr"];
    NSString *dateStr = self.dataList[indexPath.section][@"dateStr"];
    
    if (self.index) {
        M710_ScanResultController *vc = [[M710_ScanResultController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        vc.resultStr = resultStr;
        vc.dateStr = dateStr;
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        M710_CreatResultController *vc = [[M710_CreatResultController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        vc.resultStr = resultStr;
        vc.dateStr = dateStr;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)addSubView_layout{
    [self hideBackItem];
    [self setTitleStr:@"History"];
    
    SelectNavgidueView *headerView = [[SelectNavgidueView alloc] initWithFrame:CGRectZero leftTitle:@"Generate History " rightTitle:@"Scan History"];
    headerView.selectBlock = ^(NSInteger index) {
        self.index = index;
        [self reloadDataList];
    };
    [self.view addSubview:headerView];
    [headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(TOP_HEIGHT+10);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(35);
    }];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(self.view);
        make.top.equalTo(headerView.mas_bottom).offset(10);
    }];
}

- (void)reloadDataList{
    [self.dataList removeAllObjects];
    if (self.index) {
        [self.dataList addObjectsFromArray:[NSUserDefaults jk_arrayForKey:@"Scan_History"]];
    }else{
        [self.dataList addObjectsFromArray:[NSUserDefaults jk_arrayForKey:@"Creat_History"]];
    }
    [self.tableView reloadData];
}

- (void)deleteHistoryAtIndexPath:(NSIndexPath *)indexPath{
    if (self.index) {
        [self.dataList removeObjectAtIndex:indexPath.section];
        [NSUserDefaults jk_setObject:self.dataList.copy forKey:@"Scan_History"];
        [self.tableView reloadData];
    }else{
        [self.dataList removeObjectAtIndex:indexPath.section];
        [NSUserDefaults jk_setObject:self.dataList.copy forKey:@"Creat_History"];
        [self.tableView reloadData];
    }
}

- (NSMutableArray *)dataList{
    if (!_dataList) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}

-(UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.rowHeight = 100;
        _tableView.sectionFooterHeight = 5.f;
        _tableView.sectionHeaderHeight = 0.f;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[HistoryCellView class] forCellReuseIdentifier:@"HistoryCellView"];
        _tableView.backgroundColor = [UIColor clearColor];
    }
    return _tableView;
}

@end
