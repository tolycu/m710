//
//  M710_TextField.m
//  M710qr
//
//  Created by Hoho Wu on 2022/3/3.
//

#import "M710_TextField.h"

@implementation M710_TextField

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.font = [UIFont systemFontOfSize:16];
        self.textColor = [UIColor colorWithString:@"#666666"];
        self.layer.cornerRadius = 5.f;
        self.layer.masksToBounds = YES;
        self.layer.borderWidth = 1.f;
        self.layer.borderColor = [UIColor colorWithString:@"f0f0f0"].CGColor;
    }
    return self;
}

- (CGRect)textRectForBounds:(CGRect)bounds{
    return CGRectMake(10, 0, bounds.size.width-20, bounds.size.height);
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds{
    return CGRectMake(10, 0, bounds.size.width-20, bounds.size.height);
}

- (CGRect)editingRectForBounds:(CGRect)bounds{
    return CGRectMake(10, 0, bounds.size.width-20, bounds.size.height);
}

@end
