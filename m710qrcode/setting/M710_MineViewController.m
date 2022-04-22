//
//  M710_MineViewController.m
//  m710qrcode
//
//  Created by xc-76 on 2022/4/21.
//

#import "M710_MineViewController.h"

@interface M710_MineViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic ,strong) UITableView *tableView;
@property (nonatomic ,strong) NSArray *dataList;

@end

@implementation M710_MineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addSubView_layout];
}

- (void)addSubView_layout{
    [self hideBackItem];
    [self setTitleStr:@"Settings"];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.view).offset(TOP_HEIGHT+20);
    }];
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        
    }
    
    return _tableView;
}

@end
