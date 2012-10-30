//
//  PHModalViewController.h
//  Partial View Presentation
//
//  Created by Jonathan Badeen on 10/16/12.
//  Copyright (c) 2012 Jonathan Badeen. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "JLBPartialModal.h"

@interface PHModalViewController : UIViewController <JLBPartialModalDelegate>

- (IBAction)close:(id)sender;

@end
