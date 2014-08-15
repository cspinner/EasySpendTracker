//
//  spnViewController_Home.h
//  EasySpendTracker
//
//  Created by Christopher Spinner on 9/21/13.
//  Copyright (c) 2013 Christopher Spinner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"

@interface spnViewController_Home : UIViewController <UITextViewDelegate,CPTPieChartDataSource, CPTPieChartDelegate>

@property NSManagedObjectContext* managedObjectContext;

@end
