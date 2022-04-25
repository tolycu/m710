//
//  M710_MineViewController.m
//  m710qrcode
//
//  Created by xc-76 on 2022/4/21.
//

#import "M710_MineViewController.h"
#import "SettingViewCell.h"
#import "M710_AboutViewController.h"
#import "M710_RateView.h"
#import "M710_ClearCacheView.h"

@interface M710_MineViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic ,strong) UITableView *tableView;
@property (nonatomic ,strong) NSArray *dataList;

@end

@implementation M710_MineViewController

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
    if (indexPath.section == 5) {
        M710_AboutViewController *vc = [[M710_AboutViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }else if (indexPath.section == 3){
        [[M710_RateView new] show];
    }else if (indexPath.section == 4){
        M710_ClearCacheView *alterView = [[M710_ClearCacheView alloc] initWithFrame:CGRectZero title:@"Clear Cache" des:@"Clearing the cache will clear your unsaved QR code history and usage track !" btns:YES];
        [alterView show];
    }
}

- (void)addSubView_layout{
    [self hideBackItem];
    [self setTitleStr:@"Settings"];
    
    self.dataList = @[@{@"img":@"set_history",@"title":@"Save History",@"isSwitch":@(YES)},
                      @{@"img":@"set_flash",@"title":@"Flashlight",@"isSwitch":@(YES)},
                      @{@"img":@"set_share",@"title":@"Share with Friend",@"isSwitch":@(NO)},
                      @{@"img":@"set_star",@"title":@"Rate",@"isSwitch":@(NO)},
                      @{@"img":@"set_clear",@"title":@"Clear Cache",@"isSwitch":@(NO)},
                      @{@"img":@"set_aboutUs",@"title":@"About Us",@"isSwitch":@(NO)},];
    
    
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
