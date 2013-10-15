//
//  spnSpendTracker.h
//  EasySpendTracker
//
//  Created by Christopher Spinner on 9/27/13.
//  Copyright (c) 2013 Christopher Spinner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SpnTransaction.h"

@interface spnSpendTracker : NSObject 

@property NSMutableDictionary* categories;
@property (nonatomic) UIViewController* rootViewController;
@property (nonatomic) NSManagedObjectContext* managedObjectContext;

+ (spnSpendTracker*)sharedManager;
- (void)initViews;
- (void)addTransaction:(SpnTransaction*)entry forCategory:(NSString*)targetCategory;
- (void)deleteTransaction:(SpnTransaction*)entry fromCategory:(NSString*)targetCategory;
- (void)saveContext;

- (NSDateFormatter*)dateFormatterMonthDayYear; // i.e. in US locale "4/12/84" (april 12, 1984)
- (NSDateFormatter*)dateFormatterMonthYear; // i.e. "Sept 2013"
- (NSDateFormatter*)dateFormatterMonth; // i.e. "September"

@end
