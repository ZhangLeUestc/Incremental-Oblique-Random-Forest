This code is for the simple RaF tracker using HOG feature published in the following paper.
 Zhang, Le, et al. "Robust Visual Tracking Using Oblique Random Forests.", IEEE Conference on Computer Vision and Pattern Recognition (CVPR 2017), Hawaii, July, 2017

The proposed RaF is oblique and can incrementally update all internal node in a closed-from fashion. See my homepage for more details on oblique randmoized decision tree ensemble:

https://sites.google.com/site/zhangleuestc/home

The results are slightly sensitive to updating parameters. You may obtain better results by adjusting the parameters.  

As both FCNT and RaF operate in a typical particle filter framework, you can combine the tracking confidence from each particle of FCNT  ( https://github.com/scott89/FCNT) and RaF to get much better results. See our paper for more details!

This is the first version of code. We appreciate any comments/suggestions. For more quetions, please contact us via zhang.le@adsc.com.sg
	
Zhang Le
August 2017
