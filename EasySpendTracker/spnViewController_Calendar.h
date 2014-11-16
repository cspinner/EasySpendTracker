//
//  spnViewController_Calendar.h
//  EasySpendTracker
//
//  Created by Christopher Spinner on 11/7/14.
//  Copyright (c) 2014 Christopher Spinner. All rights reserved.
//

#import "Kal.h"
#import "KalViewController.h"

@interface spnViewController_Calendar : KalViewController<KalDataSource, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate>

@property (nonatomic) NSManagedObjectContext* managedObjectContext;

@end
