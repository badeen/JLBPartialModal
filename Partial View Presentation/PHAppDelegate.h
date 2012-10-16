//
//  PHAppDelegate.h
//  Partial View Presentation
//
//  Created by Jonathan Badeen on 10/16/12.
//  Copyright (c) 2012 Jonathan Badeen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PHViewController;

@interface PHAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) PHViewController *viewController;

@end
