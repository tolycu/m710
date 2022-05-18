//
//  Sport_PrivacyView.h
//  sportqr
//
//  Created by Hoho Wu on 2022/3/6.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void (^CompleteNext)(void);

@interface Sport_PrivacyView : UIView

@property(nonatomic,copy) CompleteNext nextBlock;
- (void)show;

@end

NS_ASSUME_NONNULL_END
