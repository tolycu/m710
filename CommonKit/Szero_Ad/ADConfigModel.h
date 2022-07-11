//
//  ADConfigModel.h
//  sportqr
//
//  Created by Hoho Wu on 2022/3/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface ADDataModel : NSObject

@property(nonatomic,strong) NSString *expert_type;       //广告单元类型
@property(nonatomic,assign) int expert_weight;           //权重
@property(nonatomic,strong) NSString *expert_placeId;    //广告单元
@property(nonatomic,assign) int expert_closeSize;        //关闭按钮大小

@end


@interface ADConfigModel : NSObject

@property(nonatomic,strong) NSString *expert_adPlace;  //广告位置
@property(nonatomic,assign) BOOL expert_adSwitch;        //是否请求
@property(nonatomic,strong) NSArray<ADDataModel *> *expert_adSource;   //广告数据

/**
 缓存广告
 */
@property(nonatomic,strong) id _Nullable requestAD; //请求成功的广告对象
@property(nonatomic,strong) ADDataModel *model;
@property(nonatomic,strong) NSDate *cacheDate;

@end

NS_ASSUME_NONNULL_END
