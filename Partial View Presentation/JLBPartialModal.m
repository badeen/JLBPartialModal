//
//  JLBPartialModal.m
//  Partial View Presentation
//
//  Created by Jonathan Badeen on 10/16/12.
//  Copyright (c) 2012 Jonathan Badeen. All rights reserved.
//

#import "JLBPartialModal.h"

#import <QuartzCore/QuartzCore.h>

@interface JLBPartialModalView : UIView
@end

@interface JLBPartialModalContainerViewController : UIViewController

@property (strong, nonatomic) UIViewController *contentViewController;
@property (nonatomic) BOOL showsShadow;

@end

@implementation JLBPartialModalContainerViewController

- (void)loadView
{
    self.view = [[JLBPartialModalView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
}

- (void)viewDidLoad
{
    self.view.backgroundColor = [UIColor clearColor];
}

- (void)setContentViewController:(UIViewController *)contentViewController
{
    _contentViewController = contentViewController;
}

- (void)showContentWithAnimationDuration:(NSTimeInterval)duration completion:(void (^)(BOOL finished))completion
{
    [self addChildViewController:self.contentViewController];
    self.contentViewController.view.transform = CGAffineTransformMakeTranslation(0.0f, CGRectGetHeight(self.contentViewController.view.frame));
    self.contentViewController.view.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMaxY(self.view.bounds) - (CGRectGetHeight(self.contentViewController.view.bounds) / 2.0f));
    self.contentViewController.view.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    if (self.showsShadow) {
        self.contentViewController.view.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.contentViewController.view.layer.shadowRadius = 8.0f;
        self.contentViewController.view.layer.shadowOpacity = 1.0f;
        self.contentViewController.view.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    }
    [self.view addSubview:self.contentViewController.view];
    
    [UIView animateWithDuration:duration delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.contentViewController.view.transform = CGAffineTransformIdentity;
        self.view.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.6f];
    } completion:^(BOOL finished) {
        [self.contentViewController didMoveToParentViewController:self];
        if (completion) {
            completion(finished);
        }
    }];
}

- (void)hideContentWithAnimationDuration:(NSTimeInterval)duration completion:(void (^)(BOOL finished))completion
{
    [self willMoveToParentViewController:nil];
    [UIView animateWithDuration:duration delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.contentViewController.view.transform = CGAffineTransformMakeTranslation(0.0f, CGRectGetHeight(self.contentViewController.view.frame));
        self.view.backgroundColor = [UIColor clearColor];
    } completion:^(BOOL finished) {
        [self.contentViewController removeFromParentViewController];
        if (completion) {
            completion(finished);
        }
    }];
}

@end




@interface JLBPartialModal ()

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) JLBPartialModalContainerViewController *containerViewController;
@property (strong, nonatomic) void (^dismissalBlock)(void);
@property (nonatomic, getter = isPresentingViewController) BOOL presentingViewController;
@property (nonatomic, getter = isDismissingViewController) BOOL dismissingViewController;

@end


@implementation JLBPartialModal

#define JLB_PARTIAL_MODAL_ANIMATION_DURATION 0.4f
#define JLB_PARTIAL_MODAL_WINDOW_VERTICAL_OFFSET 48.0f

+ (id)sharedInstance
{
    static id sharedInstance;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.tapToDismiss = YES;
    }
    return self;
}

#pragma mark - Presentation

- (void)presentViewController:(UIViewController *)viewControllerToPresent dismissal:(void (^)(void))block
{
    if (!self.isPresentingViewController) {
        self.presentingViewController = YES;
        self.dismissalBlock = block;
    } else {
        NSLog(@"JLBPartialModal is already presenting a view controller.");
        return;
    }
    
    self.containerViewController = [[JLBPartialModalContainerViewController alloc] init];
    self.containerViewController.contentViewController = viewControllerToPresent;
    self.containerViewController.showsShadow = self.showsShadow;
    
    // The animations and the new window to not properly show if not performed on the main thread.
    dispatch_async(dispatch_get_main_queue(), ^{
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        self.window.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.window.opaque = NO;
        self.window.backgroundColor = [UIColor clearColor];
        self.window.rootViewController = self.containerViewController;
        [self.window makeKeyAndVisible];
        
        [self.containerViewController showContentWithAnimationDuration:JLB_PARTIAL_MODAL_ANIMATION_DURATION completion:nil];
        
        __block BOOL hasCalledDelegate = NO;
        
        for (UIWindow *window in [[UIApplication sharedApplication] windows]) {
            if (window != self.window) {
                [window.layer addAnimation:[self pullBackAnimation] forKey:@"pullBackAnimation"];
                [UIView animateWithDuration:JLB_PARTIAL_MODAL_ANIMATION_DURATION animations:^{
                    window.center = CGPointMake(window.center.x, window.center.y - JLB_PARTIAL_MODAL_WINDOW_VERTICAL_OFFSET);
                } completion:^(BOOL finished) {
                    if (!hasCalledDelegate) {
                        [self.delegate didPresentPartialModalView:self];
                        hasCalledDelegate = YES;
                    }
                }];
            }
        }
    });
}

- (void)dismissViewController
{
    if (!self.isPresentingViewController) {
        NSLog(@"JLBPartialModal is not presenting a view controller to be dismissed.");
        return;
    }
    
    if (self.isDismissingViewController) {
        return;
    }
    
    if (self.delegate && ![self.delegate shouldDismissPartialModalView:self]) {
        return;
    }
    
    self.dismissingViewController = YES;
    
    // If this isn't called on the main queue, the resulting animation and removal can have a multi-second delay.
    dispatch_async(dispatch_get_main_queue(), ^{
        for (UIWindow *window in [[UIApplication sharedApplication] windows]) {
            if (window != self.window) {
                [window.layer addAnimation:[self pushForwardAnimation] forKey:@"pushForwardAnimation"];
                [UIView animateWithDuration:JLB_PARTIAL_MODAL_ANIMATION_DURATION animations:^{
                    window.center = CGPointMake(window.center.x, window.center.y + JLB_PARTIAL_MODAL_WINDOW_VERTICAL_OFFSET);
                }];
            }
        }
        
        [self.containerViewController hideContentWithAnimationDuration:JLB_PARTIAL_MODAL_ANIMATION_DURATION completion:^(BOOL finished) {
            [self.window resignKeyWindow];
            [self.window removeFromSuperview];
            self.window = nil;
            self.containerViewController = nil;
            
            for (UIWindow *window in [[UIApplication sharedApplication] windows]) {
                [window.layer removeAllAnimations];
            }
            
            self.presentingViewController = NO;
            self.dismissingViewController = NO;
            
            if (self.dismissalBlock) {
                self.dismissalBlock();
                self.dismissalBlock = nil;
            }
            
            [self.delegate didDismissPartialModalView:self];
        }];
    });
}

#pragma mark - Animations

- (CAKeyframeAnimation *)windowAnimation
{
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    anim.duration = JLB_PARTIAL_MODAL_ANIMATION_DURATION;
    anim.calculationMode = kCAAnimationCubic;
    anim.removedOnCompletion = NO;
    anim.fillMode = kCAFillModeForwards;
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    return anim;
}

- (CAKeyframeAnimation *)pullBackAnimation
{
    CATransform3D startTransform = [self perspectiveTransform];
    CATransform3D endTransform = CATransform3DConcat([self windowScaledTransform], startTransform);
    CATransform3D middleTransform = CATransform3DConcat([self windowRotationTransform], startTransform);
    
    CAKeyframeAnimation *anim = [self windowAnimation];
    anim.values = @[[NSValue valueWithCATransform3D:startTransform], [NSValue valueWithCATransform3D:middleTransform], [NSValue valueWithCATransform3D:endTransform]];
    
    return anim;
}

- (CAKeyframeAnimation *)pushForwardAnimation
{
    CATransform3D endTransform = [self perspectiveTransform];
    CATransform3D startTransform = CATransform3DConcat([self windowScaledTransform], endTransform);
    CATransform3D middleTransform = CATransform3DConcat([self windowRotationTransform], startTransform);
    
    CAKeyframeAnimation *anim = [self windowAnimation];
    anim.values = @[[NSValue valueWithCATransform3D:startTransform], [NSValue valueWithCATransform3D:middleTransform], [NSValue valueWithCATransform3D:endTransform]];
    
    return anim;
}

#pragma mark - Transforms

- (CATransform3D)windowRotationTransform
{
    return CATransform3DMakeRotation(M_PI_4 / 1.7f, 1, 0, 0);
}

- (CATransform3D)windowScaledTransform
{
    return CATransform3DMakeScale(0.8f, 0.8f, 1.0f);
}

- (CATransform3D)perspectiveTransform
{
    CATransform3D perspectiveTransform = CATransform3DIdentity;
    perspectiveTransform.m34 = 1.0f / -1000.0f;
    
    return perspectiveTransform;
}

@end

@implementation JLBPartialModalView

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([[JLBPartialModal sharedInstance] tapToDismiss]) {
        [[JLBPartialModal sharedInstance] dismissViewController];
    }
}

@end
