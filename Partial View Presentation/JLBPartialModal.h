//
//  JLBPartialModal.h
//  Partial View Presentation
//
//  Created by Jonathan Badeen on 10/16/12.
//  Copyright (c) 2012 Jonathan Badeen. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JLBPartialModalDelegate;


@interface JLBPartialModal : NSObject

@property (nonatomic) BOOL showsShadow;
@property (nonatomic) BOOL tapToDismiss;
@property (weak, nonatomic) id <JLBPartialModalDelegate> delegate;

+ (id)sharedInstance;

- (void)presentViewController:(UIViewController *)viewController dismissal:(void (^)(void))dismissalBlock;

- (void)dismissViewController;

@end


@protocol JLBPartialModalDelegate <NSObject>

@optional

- (void)didPresentPartialModalView:(JLBPartialModal *)partialModal;

- (BOOL)shouldDismissPartialModalView:(JLBPartialModal *)partialModal;

- (void)didDismissPartialModalView:(JLBPartialModal *)partialModal;

@end
