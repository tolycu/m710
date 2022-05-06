//
//  M710_ServerListController.m
//  m710qrcode
//
//  Created by xc-76 on 2022/4/25.
//

#import "M710_ServerListController.h"
#import "M710_ServerListCell.h"

@interface M710_ServerListController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic ,strong) UITableView *tableView;
@property (nonatomic ,strong) NSMutableArray<Sport_ServerVPNModel *> *dataList;

@end

@implementation M710_ServerListController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addSubView_layout];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
//    return self.dataList.count;
    return 10;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    M710_ServerListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"M710_ServerListCell" forIndexPath:indexPath];
//    cell.model = self.dataList[indexPath.section];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footer = [[UIView alloc] init];
    footer.backgroundColor = [UIColor colorWithString:@"#FAFAFA"];
    return footer;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}

- (void)addSubView_layout{
    [self setTitleStr:@"Node List"];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view);
        make.top.equalTo(self.view).offset(TOP_HEIGHT+20);
        make.left.equalTo(self.view).offset(15);
        make.right.equalTo(self.view).offset(-15);
    }];
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.rowHeight = 55.f;
        _tableView.sectionHeaderHeight = 0.f;
        _tableView.sectionFooterHeight = 10.f;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[M710_ServerListCell class] forCellReuseIdentifier:@"M710_ServerListCell"];
    }
    return _tableView;
}

- (NSMutableArray<Sport_ServerVPNModel *> *)dataList{
    if (!_dataList) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}


@end
