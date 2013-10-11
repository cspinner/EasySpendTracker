//
//  spnSpendTracker.h
//  EasySpendTracker
//
//  Created by Christopher Spinner on 9/27/13.
//  Copyright (c) 2013 Christopher Spinner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Transaction.h"

@interface spnSpendTracker : NSObject 

@property NSMutableDictionary* categories;
@property (nonatomic) UIViewController* rootViewController;
@property (nonatomic) NSManagedObjectContext* managedObjectContext;

+ (spnSpendTracker*)sharedManager;
- (void)initViews;
- (void)addTransaction:(Transaction*)entry forCategory:(NSString*)targetCategory;
- (void)deleteTransaction:(Transaction*)entry fromCategory:(NSString*)targetCategory;
- (void)saveContext;

@end
