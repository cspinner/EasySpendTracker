//
//  UIView+spnViewCategory.m
//  EasySpendTracker
//
//  Created by Christopher Spinner on 9/28/13.
//  Copyright (c) 2013 Christopher Spinner. All rights reserved.
//

#import "UIView+spnViewCategory.h"

@implementation UIView (spnViewCategory)

// Returns the first responder subview of the view
- (UIView*)spnFirstResponder
{
    if (self.isFirstResponder)
    {
        return self;
    }
    
    for (UIView *subView in self.subviews)
    {
        UIView *firstResponder = [subView spnFirstResponder];
        
        if (firstResponder != nil)
        {
            return firstResponder;
        }
    }
    
    return nil;
}

@end
