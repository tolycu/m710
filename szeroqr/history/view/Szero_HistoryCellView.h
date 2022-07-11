//
//  Szero_HistoryCellView.h
//  szeroqr
//
//  Created by xc-76 on 2022/4/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void (^DeleteIndexClick)(void);
@interface Szero_HistoryCellView : UITableViewCell

@property (nonatomic ,strong) NSDictionary *dataDict;
@property (nonatomic ,copy) DeleteIndexClick deleteBlock;

@end

NS_ASSUME_NONNULL_END
