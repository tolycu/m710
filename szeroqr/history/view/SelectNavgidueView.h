//
//  SelectNavgidueView.h
//  szeroqr
//
//  Created by xc-76 on 2022/4/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^SelectIndexClick)(NSInteger index);

@interface SelectNavgidueView : UIView

@property (nonatomic ,copy) SelectIndexClick selectBlock;

- (instancetype)initWithFrame:(CGRect)frame leftTitle:(NSString *)leftStr rightTitle:(NSString *)rightStr;

@end

NS_ASSUME_NONNULL_END
