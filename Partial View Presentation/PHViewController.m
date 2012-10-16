//
//  PHViewController.m
//  Partial View Presentation
//
//  Created by Jonathan Badeen on 10/16/12.
//  Copyright (c) 2012 Jonathan Badeen. All rights reserved.
//

#import "PHViewController.h"

#import <QuartzCore/QuartzCore.h>

#import "JLBPartialModal.h"
#import "PHModalViewController.h"

@interface PHViewController ()

@end

@implementation PHViewController {
    UIWindow *testWindow;
    UIView *_contentView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)open:(id)sender
{
    PHModalViewController *vc = [[PHModalViewController alloc] initWithNibName:nil bundle:nil];
    if (!vc.isViewLoaded) {
        [vc loadView];
    }
    vc.doneButton.action = @selector(closeModal:);
    vc.doneButton.target = self;    
    
    [[JLBPartialModal sharedInstance] presentViewController:vc dismissal:^{
        
    }];
}

- (void)closeModal:(id)sender
{
    [[JLBPartialModal sharedInstance] dismissViewController];
}

@end
