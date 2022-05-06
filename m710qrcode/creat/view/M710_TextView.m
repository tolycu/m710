//
//  M710_TextView.m
//  M710qr
//
//  Created by Hoho Wu on 2022/3/10.
//

#import "M710_TextView.h"

@interface M710_TextView ()<UITextViewDelegate>

@end

@implementation M710_TextView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setConfig];
    }
    return self;
}

- (void)addPlaceHolder:(NSString *)string{
    self.placeLab.text = string;
}

- (void)setConfig{
    self.font = [UIFont systemFontOfSize:15.f];
    self.textColor = [UIColor colorWithString:@"#1A1A1A"];
    self.textContainerInset = UIEdgeInsetsMake(15, 13, 15, 15);
    self.layer.cornerRadius = 5.f;
    self.layer.masksToBounds = YES;
    self.layer.borderWidth = 1.f;
    self.layer.borderColor = [UIColor colorWithString:@"f0f0f0"].CGColor;
    self.delegate = self;
    
    self.placeLab = [[UILabel alloc] init];
    self.placeLab.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    self.placeLab.textColor = [UIColor colorWithString:@"#bbbbbb"];
    [self addSubview:self.placeLab];
    [self.placeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(15);
        make.left.equalTo(self).offset(13);
    }];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    self.placeLab.hidden = YES;
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    if (textView.text.length) {
        self.placeLab.hidden = YES;
    }else{
        self.placeLab.hidden = NO;
    }
    return YES;
}


@end
