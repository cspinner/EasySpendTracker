//
//  spnViewController_CategorySelect.h
//  EasySpendTracker
//
//  Created by Christopher Spinner on 7/19/14.
//  Copyright (c) 2014 Christopher Spinner. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol spnViewController_CategorySelectDelegate <NSObject>

@required

- (void)categorySetName:(NSString*)category_str context:(void *)context;

@end

@interface spnTableViewController_CategorySelect : UITableViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UISearchBarDelegate, UISearchDisplayDelegate>

@property void * context;
@property NSArray* categoryTitleDictionaryArray;
@property (nonatomic) NSManagedObjectContext* managedObjectContext;
@property(nonatomic,assign) id<spnViewController_CategorySelectDelegate> delegate;

@end
