//
//  spnSpendTracker.h
//  EasySpendTracker
//
//  Created by Christopher Spinner on 9/27/13.
//  Copyright (c) 2013 Christopher Spinner. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface spnSpendTracker : NSObject 

@property (nonatomic) UIViewController* rootViewController;
@property (nonatomic) NSManagedObjectContext* managedObjectContext;

+ (spnSpendTracker*)sharedManager;
- (void)initViews;
- (void)updateAllRecurrences;

@end
