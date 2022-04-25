//
//  SettingViewCell.h
//  m710qrcode
//
//  Created by xc-76 on 2022/4/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SettingViewCell : UITableViewCell

@property (nonatomic ,strong) NSDictionary *dict;

- (void)hideRightBtn;

@end

NS_ASSUME_NONNULL_END
