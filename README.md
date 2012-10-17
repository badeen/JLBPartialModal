#JLBPartialModal

##How to Use

Show a view controller that has a predefined view size. JLBPartialModal will use the height of the view passed in.

	[[JLBPartialModal sharedInstance] presentViewController:viewController dismissal:^{
		// Code to be called when the modal has been closed
	}];

To close the modal use the following:

	[[JLBPartialModal sharedInstance] dismissViewController];

The user will also be able to tap outside your provided view to close the modal.


##Demo Video

You can watch a video of it in action here: [http://f.cl.ly/items/3P1x0I2b1l241U360V1M/JLBPartialModal%20720p.mov](http://f.cl.ly/items/3P1x0I2b1l241U360V1M/JLBPartialModal%20720p.mov "Demo video")
