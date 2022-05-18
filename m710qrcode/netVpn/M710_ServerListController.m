//
//  M710_ServerListController.m
//  m710qrcode
//
//  Created by xc-76 on 2022/4/25.
//

#import "M710_ServerListController.h"
#import "M710_ServerListCell.h"
#import "HomeAdapter.h"
#import "M710_ClearCacheView.h"


@interface M710_ServerListController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic ,strong) UITableView *tableView;
@property (nonatomic ,strong) NSMutableArray<Expert_ServerVPNModel *> *dataList;
@property (nonatomic ,strong) HomeAdapter *adapter;

@end

@implementation M710_ServerListController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addSubView_layout];
    [self reloadTableView];
}

- (void)reloadTableView{
    [self.dataList removeAllObjects];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"ping" ascending:YES];
    NSArray<Expert_ServerVPNModel *> *sortArr = [Adapter_MANAGE.servers sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [self.dataList addObjectsFromArray: sortArr];
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    M710_ServerListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"M710_ServerListCell" forIndexPath:indexPath];
    cell.vpnModel = self.dataList[indexPath.section];
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
    if ([TOOL_MANAGE checkoutSelect:self.dataList[indexPath.section]]) {
        return;
    }
    [Adapter_MANAGE changeBestServer:self.dataList[indexPath.section]];
    [self connectClick];
 
}

- (void)connectClick{
    if (TOOL_MANAGE.status == NEVPNStatusConnected) {
        M710_ClearCacheView *alterView = [[M710_ClearCacheView alloc] initWithFrame:CGRectZero title:@"Notice" des:@"Switching nodes will close the currently connected node, please confirm whether to close and connect the new node?" btns:YES];
        alterView.yesCompletionHandler = ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:Current_Connect_Model object:nil userInfo:nil];
            [self.navigationController popViewControllerAnimated:YES];
        };
        [alterView show];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:Current_Connect_Model object:nil userInfo:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }
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

- (void)loadServerList{
    [self.adapter getVpnListWithCompletionHandler:^(BOOL success, NSError * _Nonnull error) {
        [self.tableView.mj_header endRefreshing];
        [self loadPingBestServer];
    }];
}

- (void)loadPingBestServer{
    [HomeAdapter pingVPNServers:Adapter_MANAGE.servers WithCompletionHandler:^{
        [self reloadTableView];
        if (![SOneVPTool isOpenVPNForDevice]) {
            NSMutableArray *bodys = [NSMutableArray array];
            for (Expert_ServerVPNModel *model in Adapter_MANAGE.servers) {
                NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
                [dictM setValue:model.expert_host forKey:@"expert_serverIp"];
                [dictM setValue:model.expert_alisaName forKey:@"expert_serverAlias"];
                [dictM setValue:model.expert_country forKey:@"expert_serverCountry"];
                [dictM setValue:@(model.ping!=0?model.ping:1000) forKey:@"expert_pingTime"];
                [bodys addObject:dictM];
            }
            [self.adapter upLoadServersPingWithParams:bodys CompletionHandler:^(BOOL success, NSError * _Nonnull error) {
                NSLog(@"上传服务器状态");
            }];
        }
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
        _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadServerList)];
    }
    return _tableView;
}

- (NSMutableArray<Expert_ServerVPNModel *> *)dataList{
    if (!_dataList) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}

-(HomeAdapter *)adapter{
    if (!_adapter) {
        _adapter = [[HomeAdapter alloc] init];
    }
    return _adapter;
}


@end
