//
//  M710_HistoryViewController.m
//  m710qrcode
//
//  Created by xc-76 on 2022/4/21.
//

#import "M710_HistoryViewController.h"
#import "M710_ScanResultController.h"

#import "HistoryCellView.h"
#import "SelectNavgidueView.h"


@interface M710_HistoryViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic ,strong) UITableView *tableView;
@property (nonatomic ,strong) NSMutableArray *dataList;


@end

@implementation M710_HistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addSubView_layout];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 10;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HistoryCellView *cell = [tableView dequeueReusableCellWithIdentifier:@"HistoryCellView" forIndexPath:indexPath];
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
    M710_ScanResultController *vc = [[M710_ScanResultController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)addSubView_layout{
    [self hideBackItem];
    [self setTitleStr:@"History"];
    
    SelectNavgidueView *headerView = [[SelectNavgidueView alloc] initWithFrame:CGRectZero leftTitle:@"Generate History " rightTitle:@"Scan History"];
    headerView.selectBlock = ^(NSInteger index) {
        NSLog(@"选择index ---- %ld",(long)index);
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
