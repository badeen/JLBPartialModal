//
//  JLBPartialModal.h
//  Partial View Presentation
//
//  Created by Jonathan Badeen on 10/16/12.
//  Copyright (c) 2012 Jonathan Badeen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JLBPartialModal : NSObject

+ (id)sharedInstance;

- (void)presentViewController:(UIViewController *)viewController dismissal:(void (^)(void))dismissalBlock;

- (void)dismissViewController;

@end
