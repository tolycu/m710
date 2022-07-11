//
//  Szero_AboutViewController.m
//  szeroqr
//
//  Created by xc-76 on 2022/4/24.
//

#import "Szero_AboutViewController.h"
#import "Szero_WebViewController.h"
#import "SettingViewCell.h"

@interface Szero_AboutViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic ,strong) UITableView *tableView;
@property (nonatomic ,strong) NSArray *dataList;

@end

@implementation Szero_AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addSubView_layout];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SettingViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingViewCell" forIndexPath:indexPath];
    cell.dict = self.dataList[indexPath.section];
    if (indexPath.section == 2) {
        [cell hideRightBtn];
    }
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
    if (indexPath.section == 0) {
        [self pushWebWithUrl:privacy_url];
    }else if (indexPath.section == 1){
        [self pushWebWithUrl:terms_url];
    }
}

- (void)pushWebWithUrl:(NSString *)url{
    Szero_WebViewController *vc = [[Szero_WebViewController alloc] init];
    vc.url = url;
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:vc animated:YES completion:nil];
}


- (void)addSubView_layout{
    [self setTitleStr:@"Settings"];
    
    self.dataList = @[@{@"img":@"set_privacy",@"title":@"Privacy policy",@"isSwitch":@(NO)},
                      @{@"img":@"set_terms",@"title":@"Terms of service",@"isSwitch":@(NO)},
                      @{@"img":@"set_aboutUs",@"title":@"V1.0.1",@"isSwitch":@(NO)},];
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
        [_tableView registerClass:[SettingViewCell class] forCellReuseIdentifier:@"SettingViewCell"];
    }
    return _tableView;
}

@end
