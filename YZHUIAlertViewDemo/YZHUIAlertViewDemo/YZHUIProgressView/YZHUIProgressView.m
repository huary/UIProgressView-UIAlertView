//
//  YZHUIProgressView.m
//  YZHUIAlertViewDemo
//
//  Created by yuan on 2017/6/9.
//  Copyright © 2017年 yuan. All rights reserved.
//

#import "YZHUIProgressView.h"

static YZHUIProgressView *_shareProgressView_s = NULL;

@interface YZHUIProgressView ()

@property (nonatomic, strong) YZHUIAlertView *alertView;

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@property (nonatomic, assign) UIEdgeInsets animationViewEdgeInsetsRatio;
@property (nonatomic, assign) UIEdgeInsets titleViewEdgeInsetsRatio;

@end

@implementation YZHUIProgressView

+(instancetype)shareProgressView
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareProgressView_s = [[YZHUIProgressView alloc] init];
    });
    return _shareProgressView_s;
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        [self setUpDefaultValue];
        [self setUpChildView];
    }
    return self;
}

-(void)setUpDefaultValue
{
    CGFloat titleTopRatio = 0.58;
    CGFloat titleTopBottomRatio = 0.22;
    self.animationViewEdgeInsetsRatio = UIEdgeInsetsMake(0.1, 0, 1-titleTopRatio, 0);
    self.titleViewEdgeInsetsRatio = UIEdgeInsetsMake(titleTopRatio + titleTopBottomRatio/2, 20, titleTopBottomRatio/2, 20);
}

-(YZHUIAlertView*)alertView
{
    if (_alertView == nil) {
        _alertView = [[YZHUIAlertView alloc] initWithTitle:nil alertViewStyle:YZHUIAlertViewStyleAlertForce];
        _alertView.backgroundColor = CLEAR_COLOR;
        _alertView.customContentAlertView = self;
        _alertView.animateDuration = 0.0f;
    }
    return _alertView;
}

-(void)setUpChildView
{
    _animationView = [[UIImageView alloc] init];
    self.animationView.backgroundColor = CLEAR_COLOR;//PURPLE_COLOR;
    self.animationView.contentMode = UIViewContentModeCenter;
    [self addSubview:self.animationView];
    
    _titleView = [[UILabel alloc] init];
    self.titleView.font = FONT(18);
    self.titleView.backgroundColor = CLEAR_COLOR;//RED_COLOR;
    self.titleView.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.titleView];
    
    self.backgroundColor = BLACK_COLOR;
    
    _progressViewStyle = YZHUIProgressViewStyleIndicator;
    [self _updateIndicatorView];
    
    [self setContentColor:WHITE_COLOR];
}

//-(BOOL)_checkInsetsRatio:(UIEdgeInsets)insetRatio
//{
//    CGFloat diff = 1 - insetRatio.left - insetRatio.right;
//    if (diff <= 0) {
//        return NO;
//    }
//    diff = 1 - insetRatio.top - insetRatio.bottom;
//    if (diff <= 0) {
//        return NO;
//    }
//    return YES;
//}
//
//-(void)setTitleViewEdgeInsetsRatio:(UIEdgeInsets)titleViewEdgeInsetsRatio
//{
//    if (![self _checkInsetsRatio:titleViewEdgeInsetsRatio]) {
//        return;
//    }
//    _titleViewEdgeInsetsRatio = titleViewEdgeInsetsRatio;
//}
//
//-(void)setAnimationViewEdgeInsetsRatio:(UIEdgeInsets)animationViewEdgeInsetsRatio
//{
//    if (![self _checkInsetsRatio:animationViewEdgeInsetsRatio]) {
//        return;
//    }
//    _animationViewEdgeInsetsRatio = animationViewEdgeInsetsRatio;
//}

-(void)setCustomView:(UIView *)customView
{
    if (_customView != customView) {
        _customView = customView;
        if (customView) {
            [self addSubview:customView];
        }
    }
}

-(void)_doClearAnimationView
{
    [self.animationView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.animationView stopAnimating];
    self.animationView.animationImages = nil;
    self.animationView.image = nil;
}

-(void)_updateIndicatorView
{
    [self _doClearAnimationView];
    if (_progressViewStyle == YZHUIProgressViewStyleIndicator)
    {
        [self.indicatorView removeFromSuperview];
        self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.indicatorView.color = self.contentColor;
        [self.indicatorView startAnimating];
        [self.animationView addSubview:self.indicatorView];
    }
}

-(void)setProgressViewStyle:(YZHUIProgressViewStyle)progressViewStyle
{
//    if (_progressViewStyle != progressViewStyle) {
        _progressViewStyle = progressViewStyle;
        [self _updateIndicatorView];
//    }
}

-(void)setContentColor:(UIColor *)contentColor
{
    if (_contentColor != contentColor) {
        _contentColor = contentColor;
        self.titleView.textColor = contentColor;
        self.indicatorView.color = contentColor;
    }
}

-(void)setShowTimeInterval:(NSTimeInterval)showTimeInterval
{
    _showTimeInterval = showTimeInterval;
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(_doTimeoutAction) object:nil];
    if (showTimeInterval > 0) {
//        DISPATCH_MAIN_THREAD_ASYNC(^{
        [self performSelector:@selector(_doTimeoutAction) withObject:nil afterDelay:showTimeInterval];
//        });
    }
    else {
        self.timeoutBlock = nil;
    }
}

-(void)_doTimeoutAction
{
    if (self.timeoutBlock) {
        YZHUIProgressTimeoutBlock timeoutBlock = self.timeoutBlock;
        self.timeoutBlock = nil;
        timeoutBlock(self);
    }
    else
    {
        [self dismiss];
    }
}

-(void)_doCompletionBlock:(BOOL)finished
{
    if (self.completionBlock) {
        self.completionBlock(self, self.dismissTag, finished);
    }
}

-(void)setCompletionBlock:(YZHUIProgressDismissCompletionBlock)completionBlock
{
    _completionBlock = completionBlock;
    WEAK_SELF(weakSelf);
    self.alertView.dismissCompletionBlock = ^(YZHUIAlertView *alertView ,BOOL finished) {
        [weakSelf _doCompletionBlock:finished];
    };
}

-(CGSize)_getContentSizeByContent
{
    [self.titleView sizeToFit];
    [self.animationView sizeToFit];
    CGSize titleSize = self.titleView.bounds.size;
    CGSize animationSize = self.animationView.bounds.size;
    CGFloat width = 0;
    CGFloat height = 0;
    UIEdgeInsets insetsRatio = UIEdgeInsetsZero;
    if (!CGSizeEqualToSize(titleSize, CGSizeZero)) {
        insetsRatio = self.titleViewEdgeInsetsRatio;
        width = titleSize.width + insetsRatio.left + insetsRatio.right;
        height = titleSize.height;
    }
    else if (!CGSizeEqualToSize(animationSize, CGSizeZero))
    {
        insetsRatio = self.animationViewEdgeInsetsRatio;
        width = animationSize.width;
        height = animationSize.height;
    }
    //        if (insetsRatio.left + insetsRatio.right < 1) {
    //            width = width / (1 - insetsRatio.left - insetsRatio.right);
    //        }
    if (insetsRatio.top + insetsRatio.bottom < 1) {
        height = height / (1 - insetsRatio.top - insetsRatio.bottom);
    }
    return CGSizeMake(width, height);
}

-(CGSize)_getContentSize
{
    CGSize size = self.bounds.size;
    CGSize contentSize = [self _getContentSizeByContent];
//    if (contentSize.width >= size.width && contentSize.height >= size.height) {
//        size = contentSize;
//    }
    if (CGSizeEqualToSize(size, contentSize) == NO) {
        size = contentSize;
    }
    return size;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    CGSize size = [self _getContentSize];
    self.frame = CGRectMake(0, 0, size.width, size.height);
    UIEdgeInsets insetRatio = self.titleViewEdgeInsetsRatio;
//    self.titleView.frame = CGRectMake(insetRatio.left * size.width, insetRatio.top * size.height, (1-insetRatio.left-insetRatio.right) * size.width, (1-insetRatio.top-insetRatio.bottom) * size.height);
    self.titleView.frame = CGRectMake(0, insetRatio.top * size.height, size.width, (1-insetRatio.top-insetRatio.bottom) * size.height);
    
    insetRatio = self.animationViewEdgeInsetsRatio;
//    self.animationView.frame = CGRectMake(insetRatio.left * size.width, insetRatio.top * size.height, (1-insetRatio.left-insetRatio.right) * size.width, (1-insetRatio.top-insetRatio.bottom) * size.height);
    self.animationView.frame = CGRectMake(insetRatio.left * size.width, insetRatio.top * size.height, size.width, (1-insetRatio.top-insetRatio.bottom) * size.height);
    if (self.customView) {
        self.customView.frame = self.bounds;
    }
    
    if (self.indicatorView) {
        self.indicatorView.frame = self.animationView.bounds;
    }
}

-(void)_doUpdateAnimationImages:(NSArray<UIImage*>*)animationImages
{
    if (IS_AVAILABLE_NSSET_OBJ(animationImages)) {
        [self _doClearAnimationView];
    }
    if (animationImages.count > 1) {
        self.animationView.animationImages = animationImages;
        [self.animationView startAnimating];
    }
    else if (animationImages.count == 1)
    {
        self.animationView.image = [animationImages firstObject];
    }
}

-(void)setOutSideUserInteractionEnabled:(BOOL)outSideUserInteractionEnabled
{
    _outSideUserInteractionEnabled = outSideUserInteractionEnabled;
    self.alertView.outSideUserInteractionEnabled = outSideUserInteractionEnabled;
}

-(void)progressShowInView:(UIView*)view withAnimationImages:(NSArray<UIImage *> *)animationImages
{
    [self _updateIndicatorView];
    [self _doUpdateAnimationImages:animationImages];
    [self _doUpdateProgressView];
    
    _isShowing = YES;
    [self.alertView alertShowInView:view];
}

-(void)progressShowTitleText:(NSString*)titleText
{
    [self progressShowInView:nil titleText:titleText];
}

-(void)progressShowInView:(UIView *)view titleText:(NSString*)titleText
{
    [self progressShowInView:view titleText:titleText showTimeInterval:0 timeoutBlock:nil];
}

-(void)progressShowTitleText:(NSString*)titleText showTimeInterval:(NSTimeInterval)showTimeInterval
{
    [self progressShowTitleText:titleText showTimeInterval:showTimeInterval timeoutBlock:nil];
}

-(void)progressShowTitleText:(NSString*)titleText showTimeInterval:(NSTimeInterval)showTimeInterval timeoutBlock:(YZHUIProgressTimeoutBlock)timeoutBlock
{
    [self progressShowInView:nil titleText:titleText showTimeInterval:showTimeInterval timeoutBlock:timeoutBlock];
}

-(void)progressShowInView:(UIView *)view titleText:(NSString*)titleText showTimeInterval:(NSTimeInterval)showTimeInterval
{
    [self progressShowInView:view titleText:titleText showTimeInterval:showTimeInterval timeoutBlock:nil];
}

-(void)progressShowInView:(UIView *)view titleText:(NSString*)titleText showTimeInterval:(NSTimeInterval)showTimeInterval timeoutBlock:(YZHUIProgressTimeoutBlock)timeoutBlock
{
    [self progressShowInView:view titleText:titleText animationImages:nil showTimeInterval:showTimeInterval timeoutBlock:timeoutBlock];
}

-(void)progressShowTitleText:(NSString*)titleText animationImages:(NSArray<UIImage*>*)animationImages
{
    [self progressShowTitleText:titleText animationImages:animationImages showTimeInterval:0 timeoutBlock:nil];
}

-(void)progressShowTitleText:(NSString*)titleText animationImages:(NSArray<UIImage*>*)animationImages showTimeInterval:(NSTimeInterval)showTimeInterval
{
    [self progressShowTitleText:titleText animationImages:animationImages showTimeInterval:showTimeInterval timeoutBlock:nil];
}

-(void)progressShowTitleText:(NSString*)titleText animationImages:(NSArray<UIImage*>*)animationImages showTimeInterval:(NSTimeInterval)showTimeInterval timeoutBlock:(YZHUIProgressTimeoutBlock)timeoutBlock
{
    [self progressShowInView:nil titleText:titleText animationImages:animationImages showTimeInterval:showTimeInterval timeoutBlock:timeoutBlock];
}

-(void)progressShowInView:(UIView *)view titleText:(NSString*)titleText animationImages:(NSArray<UIImage*>*)animationImages showTimeInterval:(NSTimeInterval)showTimeInterval
{
    [self progressShowInView:view titleText:titleText animationImages:animationImages showTimeInterval:showTimeInterval timeoutBlock:nil];
}

-(void)progressShowInView:(UIView *)view titleText:(NSString*)titleText animationImages:(NSArray<UIImage*>*)animationImages showTimeInterval:(NSTimeInterval)showTimeInterval timeoutBlock:(YZHUIProgressTimeoutBlock)timeoutBlock
{
    self.titleView.text = titleText;
    self.showTimeInterval = showTimeInterval;
    self.timeoutBlock = timeoutBlock;
    [self progressShowInView:view withAnimationImages:animationImages];
}

-(void)_doUpdateProgressView
{    
    CGSize size = [self _getContentSize];
    self.alertView.bounds = CGRectMake(0, 0, size.width, size.height);
}

-(void)updateTitleText:(NSString*)titleText
{
    self.titleView.text = titleText;
    [self _doUpdateProgressView];
}

-(void)updateTitleText:(NSString*)titleText showTimeInterval:(NSTimeInterval)showTimeInterval
{
    [self updateTitleText:titleText showTimeInterval:showTimeInterval timeoutBlock:nil];
}

-(void)updateTitleText:(NSString*)titleText showTimeInterval:(NSTimeInterval)showTimeInterval timeoutBlock:(YZHUIProgressTimeoutBlock)timeoutBlock
{
    self.titleView.text = titleText;
    self.showTimeInterval = showTimeInterval;
    self.timeoutBlock = timeoutBlock;
    [self _doUpdateProgressView];
}

-(void)updateAnimationImages:(NSArray<UIImage*>*)animationImages
{
    [self _doUpdateAnimationImages:animationImages];
    [self _doUpdateProgressView];
}

-(void)updateAnimationImages:(NSArray<UIImage*>*)animationImages showTimeInterval:(NSTimeInterval)showTimeInterval
{
    [self updateAnimationImages:animationImages showTimeInterval:showTimeInterval timeoutBlock:nil];
}

-(void)updateAnimationImages:(NSArray<UIImage*>*)animationImages showTimeInterval:(NSTimeInterval)showTimeInterval timeoutBlock:(YZHUIProgressTimeoutBlock)timeoutBlock
{
    self.showTimeInterval = showTimeInterval;
    self.timeoutBlock = timeoutBlock;
    [self _doUpdateAnimationImages:animationImages];
    [self _doUpdateProgressView];
}

-(void)updateTitleText:(NSString *)titleText animationImages:(NSArray<UIImage*>*)animationImages
{
    self.titleView.text = titleText;
    [self _doUpdateAnimationImages:animationImages];
    [self _doUpdateProgressView];
}

-(void)updateTitleText:(NSString *)titleText animationImages:(NSArray<UIImage *> *)animationImages showTimeInterval:(NSTimeInterval)showTimeInterval
{
    [self updateTitleText:titleText animationImages:animationImages showTimeInterval:showTimeInterval timeoutBlock:nil];
}

-(void)updateTitleText:(NSString *)titleText animationImages:(NSArray<UIImage *> *)animationImages showTimeInterval:(NSTimeInterval)showTimeInterval timeoutBlock:(YZHUIProgressTimeoutBlock)timeoutBlock
{
    self.titleView.text = titleText;
    self.timeoutBlock = timeoutBlock;
    self.showTimeInterval = showTimeInterval;
    [self _doUpdateAnimationImages:animationImages];
    [self _doUpdateProgressView];
}

-(void)dismiss
{
    //这里不能用self.alertView,因为这里重写了get方法
    [_alertView dismiss];
    _isShowing = NO;
    self.alertView = nil;
    self.showTimeInterval = 0;
}

-(void)removeFromSuperview
{
    if (self.customView) {
        [self.customView removeFromSuperview];
        self.customView = nil;
    }
//    [self dismiss];
    [super removeFromSuperview];
}

-(void)dealloc
{
    NSLog(@"YZHUIProgressView--------dealloc");
}
@end
