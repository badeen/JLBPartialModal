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

You can watch a video of it in action here: [http://f.cl.ly/items/3J0F2n2N2Q3E313V3f3O/JLBPartialModal.mov](http://f.cl.ly/items/3J0F2n2N2Q3E313V3f3O/JLBPartialModal.mov "Demo video")
