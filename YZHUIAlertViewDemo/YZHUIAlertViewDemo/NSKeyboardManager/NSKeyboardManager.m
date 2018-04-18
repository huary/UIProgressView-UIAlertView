//
//  NSKeyboardManager.m
//  易阅卷
//
//  Created by yuan on 2017/6/22.
//  Copyright © 2017年 yuan. All rights reserved.
//

#import "NSKeyboardManager.h"

//static NSKeyboardManager *_shareKeyboardManager_s=nil;

@interface NSKeyboardManager ()

@property (nonatomic, assign) BOOL isSpecialFirstResponderView;

@property (nonatomic, assign) CGAffineTransform relatedShiftViewOriginalTransform;

@end

@implementation NSKeyboardManager

-(instancetype)init
{
    self = [super init];
    if (self) {
        [self setUpDefault];
    }
    return self;
}

#if 0
+(instancetype)shareKeyboardManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareKeyboardManager_s = [[super allocWithZone:NULL] init];
        [_shareKeyboardManager_s setUpDefault];
    });
    return _shareKeyboardManager_s;
}

+(id)allocWithZone:(struct _NSZone *)zone
{
    return [NSKeyboardManager shareKeyboardManager];
}

-(id)copyWithZone:(struct _NSZone *)zone
{
    return [NSKeyboardManager shareKeyboardManager];
}
#endif

-(void)setUpDefault
{
    self.isSpecialFirstResponderView = NO;
    [self _registerAllNotification:YES];
}

-(void)setRelatedShiftView:(UIView *)relatedShiftView
{
    _relatedShiftView = relatedShiftView;
    self.relatedShiftViewOriginalTransform = relatedShiftView.transform;
}

-(void)setFirstResponderView:(UIView *)firstResponderView
{
    _firstResponderView = firstResponderView;
    if (_firstResponderView != nil) {
        self.isSpecialFirstResponderView = YES;
    }
}

-(void)_registerAllNotification:(BOOL)regist
{
    [self _registerFirstResponderViewNotification:regist didBecomeFirstResponderNotificationName:UITextFieldTextDidBeginEditingNotification didResignFirstResponderNotificationName:UITextFieldTextDidEndEditingNotification];
    [self _registerFirstResponderViewNotification:regist didBecomeFirstResponderNotificationName:UITextViewTextDidBeginEditingNotification didResignFirstResponderNotificationName:UITextViewTextDidEndEditingNotification];
    
    [self _registerKeyboardNotification:regist];
    
//    [self _registerStatusBarNotification:regist];
}

-(void)_registerKeyboardNotification:(BOOL)regist
{
    if (regist) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    }
}

-(void)_registerFirstResponderViewNotification:(BOOL)regist didBecomeFirstResponderNotificationName:(NSString*)becomeNotificationName didResignFirstResponderNotificationName:(NSString*)resignNotificationName
{
    if (regist) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didBecomeFirstResponder:) name:becomeNotificationName object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didResignFirstResponder:) name:resignNotificationName object:nil];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:becomeNotificationName object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:resignNotificationName object:nil];
    }
}

-(void)_registerStatusBarNotification:(BOOL)regist
{
    if (regist) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didChangeStatusBarFrame:) name:UIApplicationDidChangeStatusBarFrameNotification object:[UIApplication sharedApplication]];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarFrameNotification object:[UIApplication sharedApplication]];
    }
}

-(void)_doUpdateWithKeyboardFrame:(CGRect)keyboardFrame duration:(NSTimeInterval)duration isHide:(BOOL)isHide
{
    CGRect firstResponderViewFrame = self.firstResponderView.frame;
    firstResponderViewFrame = [self.firstResponderView.superview convertRect:firstResponderViewFrame toView:[UIApplication sharedApplication].keyWindow];
    
    void (^animateCompletionBlock)(BOOL finished) = ^(BOOL finished){
        if (isHide && self.didHideBlock) {
            self.didHideBlock(self);
        }
    };
    
    CGFloat diffY = keyboardFrame.origin.y - CGRectGetMaxY(firstResponderViewFrame) - self.keyboardMinTop;
    if (diffY > 0) {
        [UIView animateWithDuration:duration animations:^{
            self.relatedShiftView.transform = self.relatedShiftViewOriginalTransform;
        } completion:animateCompletionBlock];
        return;
    }
    
    CGFloat oldTranslationY = self.relatedShiftView.transform.ty;
    
    CGFloat ty = oldTranslationY + diffY;
    
    [UIView animateWithDuration:duration animations:^{
        self.relatedShiftView.transform = CGAffineTransformMakeTranslation(0, ty);
    } completion:animateCompletionBlock];
}

#pragma mark firstResponder
-(void)_didBecomeFirstResponder:(NSNotification*)notification
{
    if (self.isSpecialFirstResponderView) {
        return;
    }
    _firstResponderView = notification.object;
}

-(void)_didResignFirstResponder:(NSNotification*)notification
{
    if (self.isSpecialFirstResponderView) {
        return;
    }
    _firstResponderView = nil;
}

#pragma mark statusBarFrame
-(void)_didChangeStatusBarFrame:(NSNotification*)notification
{
}


#pragma mark keyBoard

-(void)_keyBoardWillShow:(NSNotification*)notification
{
    NSTimeInterval time = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    CGRect keyBoardFrame = CGRectZero;
    [notification.userInfo[UIKeyboardFrameEndUserInfoKey] getValue:&keyBoardFrame];

    if (self.willShowBlock) {
        self.willShowBlock(self);
    }
    
    [self _doUpdateWithKeyboardFrame:keyBoardFrame duration:time isHide:NO];
}

-(void)_keyBoardWillHide:(NSNotification*)notification
{
    NSTimeInterval time = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    CGRect keyBoardFrame = CGRectZero;
    [notification.userInfo[UIKeyboardFrameEndUserInfoKey] getValue:&keyBoardFrame];
    
    if (self.willHideBlock) {
        self.willHideBlock(self);
    }
    [self _doUpdateWithKeyboardFrame:keyBoardFrame duration:time isHide:YES];
}

-(void)dealloc
{
    [self _registerAllNotification:NO];
}

@end





/*****************************************************************************
 *NSShareKeyboardManager
 *****************************************************************************/
static NSShareKeyboardManager *_shareKeyboardManager_s=nil;


@implementation NSShareKeyboardManager

+(instancetype)shareKeyboardManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareKeyboardManager_s = [[super allocWithZone:NULL] init];
        [_shareKeyboardManager_s _setUpDefault];
    });
    return _shareKeyboardManager_s;
}

-(void)_setUpDefault
{
    _keyboardManager = [[NSKeyboardManager alloc] init];
}

+(id)allocWithZone:(struct _NSZone *)zone
{
    return [NSShareKeyboardManager shareKeyboardManager];
}

-(id)copyWithZone:(struct _NSZone *)zone
{
    return [NSShareKeyboardManager shareKeyboardManager];
}

@end
