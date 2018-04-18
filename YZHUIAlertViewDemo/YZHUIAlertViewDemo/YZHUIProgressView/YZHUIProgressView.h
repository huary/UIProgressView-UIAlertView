//
//  YZHUIProgressView.h
//  YZHUIAlertViewDemo
//
//  Created by yuan on 2017/6/9.
//  Copyright © 2017年 yuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YZHUIAlertView.h"

typedef NS_ENUM(NSInteger, YZHUIProgressViewStyle)
{
//    YZHUIProgressViewStyleNULL          = -1,
    YZHUIProgressViewStyleIndicator     = 0,
};

@class YZHUIProgressView;
typedef void(^YZHUIProgressTimeoutBlock)(YZHUIProgressView *progressView);
typedef void(^YZHUIProgressDismissCompletionBlock)(YZHUIProgressView *progressView,NSInteger dismissTag, BOOL finished);

@interface YZHUIProgressView : UIView

@property (nonatomic, strong, readonly) UIImageView *animationView;
@property (nonatomic, strong, readonly) UILabel *titleView;

//在completionBlock回调回来的
@property (nonatomic, assign) NSInteger dismissTag;

/*
 *指定为weak，是怕出现循环应用的问题，可以在dimss时界面循环引用，但是如果没有调用dismiss时
 *或者调用removeFromSupperView(已在removefromsupperview上做解除循环引用)等其他的方法时没法解除循环应用，
 *为了保险起见使用weak(这里支持使用strong，不会出现循环引用的问题)
 */
@property (nonatomic, strong) UIView *customView;

//在设置这些属性（contentColor、progressViewStyle、showTimeInterval）的都需要在主线程
@property (nonatomic, copy) UIColor *contentColor;

@property (nonatomic, assign) YZHUIProgressViewStyle progressViewStyle;

@property (nonatomic, assign) NSTimeInterval showTimeInterval;

//此timeoutBlock为showTimeInterval结束时调用，并且不会调用dismiss。只会调用一次，在调用时已经置空，否则有可能出现死循环
@property (nonatomic, copy) YZHUIProgressTimeoutBlock timeoutBlock;
//此completionBlock为在dismiss后回调
@property (nonatomic, copy) YZHUIProgressDismissCompletionBlock completionBlock;

@property (nonatomic, assign, readonly) BOOL isShowing;

@property (nonatomic, assign) BOOL outSideUserInteractionEnabled;

//提供了一个share的全局对象，不是单例
+(instancetype)shareProgressView;

-(void)progressShowTitleText:(NSString*)titleText;

-(void)progressShowInView:(UIView *)view titleText:(NSString*)titleText;

-(void)progressShowTitleText:(NSString*)titleText showTimeInterval:(NSTimeInterval)showTimeInterval;

-(void)progressShowTitleText:(NSString*)titleText showTimeInterval:(NSTimeInterval)showTimeInterval timeoutBlock:(YZHUIProgressTimeoutBlock)timeoutBlock;

-(void)progressShowInView:(UIView *)view titleText:(NSString*)titleText showTimeInterval:(NSTimeInterval)showTimeInterval;

-(void)progressShowInView:(UIView *)view titleText:(NSString*)titleText showTimeInterval:(NSTimeInterval)showTimeInterval timeoutBlock:(YZHUIProgressTimeoutBlock)timeoutBlock;

-(void)progressShowTitleText:(NSString*)titleText animationImages:(NSArray<UIImage*>*)animationImages;

-(void)progressShowTitleText:(NSString*)titleText animationImages:(NSArray<UIImage*>*)animationImages showTimeInterval:(NSTimeInterval)showTimeInterval;

-(void)progressShowTitleText:(NSString*)titleText animationImages:(NSArray<UIImage*>*)animationImages showTimeInterval:(NSTimeInterval)showTimeInterval timeoutBlock:(YZHUIProgressTimeoutBlock)timeoutBlock;

-(void)progressShowInView:(UIView *)view titleText:(NSString*)titleText animationImages:(NSArray<UIImage*>*)animationImages showTimeInterval:(NSTimeInterval)showTimeInterval;

-(void)progressShowInView:(UIView *)view titleText:(NSString*)titleText animationImages:(NSArray<UIImage*>*)animationImages showTimeInterval:(NSTimeInterval)showTimeInterval timeoutBlock:(YZHUIProgressTimeoutBlock)timeoutBlock;

-(void)updateTitleText:(NSString*)titleText;

//原来的计时作废,从update后开始计时，下同
-(void)updateTitleText:(NSString*)titleText showTimeInterval:(NSTimeInterval)showTimeInterval;

-(void)updateTitleText:(NSString*)titleText showTimeInterval:(NSTimeInterval)showTimeInterval  timeoutBlock:(YZHUIProgressTimeoutBlock)timeoutBlock;

-(void)updateAnimationImages:(NSArray<UIImage*>*)animationImages;

-(void)updateAnimationImages:(NSArray<UIImage*>*)animationImages showTimeInterval:(NSTimeInterval)showTimeInterval;

-(void)updateAnimationImages:(NSArray<UIImage*>*)animationImages showTimeInterval:(NSTimeInterval)showTimeInterval timeoutBlock:(YZHUIProgressTimeoutBlock)timeoutBlock;

-(void)updateTitleText:(NSString *)titleText animationImages:(NSArray<UIImage*>*)animationImages;

-(void)updateTitleText:(NSString *)titleText animationImages:(NSArray<UIImage*>*)animationImages showTimeInterval:(NSTimeInterval)showTimeInterval;

-(void)updateTitleText:(NSString *)titleText animationImages:(NSArray<UIImage*>*)animationImages showTimeInterval:(NSTimeInterval)showTimeInterval timeoutBlock:(YZHUIProgressTimeoutBlock)timeoutBlock;

-(void)dismiss;

@end
