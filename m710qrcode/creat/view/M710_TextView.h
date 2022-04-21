//
//  M710_TextView.h
//  M710qr
//
//  Created by Hoho Wu on 2022/3/10.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface M710_TextView : UITextView

@property (nonatomic ,strong) UILabel *placeLab;
- (void)addPlaceHolder:(NSString *)string;

@end

NS_ASSUME_NONNULL_END
