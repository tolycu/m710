//
//  M710_CreatViewController.m
//  m710qrcode
//
//  Created by xc-76 on 2022/4/21.
//

#import "M710_CreatViewController.h"
#import "M710_FolderViewCell.h"
#import "M710_CreatResultController.h"

@interface M710_CreatViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic ,strong) UICollectionView *collectView;
@property (nonatomic ,strong) NSArray *dataList;

@end

@implementation M710_CreatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addSubView_layout];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataList.count;
}

-(__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    M710_FolderViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"M710_FolderViewCell" forIndexPath:indexPath];
    cell.dict = self.dataList[indexPath.item];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    M710_CreatResultController *vc = [[M710_CreatResultController alloc] init];
//    if (indexPath.item == 0) {
//        vc.qrType = DataStringQRType_url;
//    }else if (indexPath.item == 1){
//        vc.qrType = DataStringQRType_text;
//    }else if (indexPath.item == 2){
//        vc.qrType = DataStringQRType_vcard;
//    }else if (indexPath.item == 3){
//        vc.qrType = DataStringQRType_mecard;
//    }else if (indexPath.item == 4){
//        vc.qrType = DataStringQRType_phone;
//    }else if (indexPath.item == 5){
//        vc.qrType = DataStringQRType_sms;
//    }
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
        [_collectView registerClass:[M710_FolderViewCell class] forCellWithReuseIdentifier:@"M710_FolderViewCell"];
    }
    return _collectView;
}

@end
