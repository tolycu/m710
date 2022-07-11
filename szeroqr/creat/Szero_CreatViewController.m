//
//  Szero_CreatViewController.m
//  szeroqr
//
//  Created by xc-76 on 2022/4/21.
//

#import "Szero_CreatViewController.h"
#import "Szero_FolderViewCell.h"
#import "Szero_EditQRController.h"
#import "Szero_CreatResultController.h"

@interface Szero_CreatViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic ,strong) UICollectionView *collectView;
@property (nonatomic ,strong) NSArray *dataList;

//底部横幅广告
@property(nonatomic,strong) ADConfigModel *bannerModel;
@property(nonatomic,strong) GADBannerView *bannerView;
@property(nonatomic,strong) NSTimer *loadTimer;
@property(nonatomic,assign) NSInteger longTime; //检测广告时长 30s

@end

@implementation Szero_CreatViewController

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [FIRAnalytics logEventWithName:Show_create_generate parameters:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self showBannerAD];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addSubView_layout];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataList.count;
}

-(__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    Szero_FolderViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Szero_FolderViewCell" forIndexPath:indexPath];
    cell.dict = self.dataList[indexPath.item];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    Szero_EditQRController *vc = [[Szero_EditQRController alloc] init];
    if (indexPath.item == 0) {
        vc.type = DataStringQRType_card;
    }else if (indexPath.item == 1){
        vc.type = DataStringQRType_Twitter;
    }else if (indexPath.item == 2){
        vc.type = DataStringQRType_barcode;
    }else if (indexPath.item == 3){
        vc.type = DataStringQRType_FB;
    }else if (indexPath.item == 4){
        vc.type = DataStringQRType_url;
    }else if (indexPath.item == 5){
        vc.type = DataStringQRType_text;
    }else if (indexPath.item == 6){
        vc.type = DataStringQRType_wifi;
    }else if (indexPath.item == 7){
        vc.type = DataStringQRType_whatsapp;
    }else if (indexPath.item == 8){
        vc.type = DataStringQRType_phone;
    }
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)addSubView_layout{
    [self hideBackItem];
    [self setTitleStr:@"Creater"];
    
    self.dataList = @[@{@"img":@"creat_card",@"title":@"Business Card",@"color":@"#F05E63"},
                      @{@"img":@"creat_twitter",@"title":@"Twitter",@"color":@"#49B2EA"},
                      @{@"img":@"creat_bar",@"title":@"Bar Code",@"color":@"#1A1A1A"},
                      @{@"img":@"creat_facebook",@"title":@"FaceBook",@"color":@"#636B9C"},
                      @{@"img":@"creat_url",@"title":@"Urls",@"color":@"#AB6FB7"},
                      @{@"img":@"creat_text",@"title":@"Text",@"color":@"#F9DD6F"},
                      @{@"img":@"creat_wifi",@"title":@"Wifi",@"color":@"#7EBBD2"},
                      @{@"img":@"creat_whatsapp",@"title":@"Whatsapp",@"color":@"#79E1A0"},
                      @{@"img":@"creat_phone",@"title":@"Phone Number",@"color":@"#F09852"},];
    [self.view addSubview:self.collectView];
    [self.collectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.left.bottom.equalTo(self.view);
        make.top.equalTo(self.view).offset(TOP_HEIGHT+20);
    }];
}

- (UICollectionView *)collectView{
    if (!_collectView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 15.f;
        layout.minimumInteritemSpacing = 15.f;
        layout.itemSize = CGSizeMake((XCScreenW-45)/2, 140);
        
        _collectView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectView.contentInset = UIEdgeInsetsMake(0, 15, 0, 15);
        _collectView.backgroundColor = [UIColor clearColor];
        _collectView.delegate = self;
        _collectView.dataSource = self;
        [_collectView registerClass:[Szero_FolderViewCell class] forCellWithReuseIdentifier:@"Szero_FolderViewCell"];
    }
    return _collectView;
}

#pragma mark - 底部广告
- (void)showBannerAD{
    if (!self.loadTimer) {
        self.longTime = 0;
        self.loadTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(loadShowBannerAD) userInfo:nil repeats:YES];
    }
}

- (void)loadShowBannerAD{
    self.longTime = +2;
    if (self.longTime > 30 && self.loadTimer) {
        [self.loadTimer invalidate];
        self.loadTimer = nil;
    }
    
    self.bannerModel = [ADConfigSetting filterADPosition:ADPositionType_home];
    if (!self.bannerModel) {
        [self.collectView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view);
        }];
        return;
    }
    [self.loadTimer invalidate];
    self.loadTimer = nil;
    ADDataType temp = [ADConfigSetting getLoadADtype:self.bannerModel.model.expert_type];
    if(temp == ADDataType_banner &&
       [NSStringFromClass([self.bannerModel.requestAD class]) isEqualToString:@"GADBannerView"]){
        self.bannerView = (GADBannerView *)self.bannerModel.requestAD;
        self.bannerView.rootViewController = [self currentController];
        [self.view addSubview:self.bannerView];
        [self.bannerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-10);
            make.height.mas_equalTo(50);
        }];
        
        [self.collectView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view).offset(-60);
        }];
    }
}

@end
