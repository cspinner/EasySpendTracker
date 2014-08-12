//
//  SpnRecurrence.h
//  EasySpendTracker
//
//  Created by Christopher Spinner on 6/16/14.
//  Copyright (c) 2014 Christopher Spinner. All rights reserved.
//

#import "SpnRecurrenceMO.h"

typedef NS_ENUM(NSInteger, SpnRecurrenceActionType)
{
    RECUR_ACTION_NONE,
    RECUR_ACTION_CREATE,
    RECUR_ACTION_DELETE_ALL,
    RECUR_ACTION_DELETE_FUTURE,
    RECUR_ACTION_DELETE_ONE,
    RECUR_ACTION_UPDATE_ALL,
    RECUR_ACTION_UPDATE_FUTURE,
    RECUR_ACTION_UPDATE_ONE
};

@interface SpnRecurrence : SpnRecurrenceMO

- (void)setRecurrenceForTransaction:(SpnTransaction*)transaction withFrequency:(NSDateComponents*)frequency withAction:(SpnRecurrenceActionType)action;
- (void)extendSeriesThroughEndOfMonth;


@end
