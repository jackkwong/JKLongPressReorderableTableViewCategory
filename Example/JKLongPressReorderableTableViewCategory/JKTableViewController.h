//
//  JKTableViewController.h
//  JKLongPressReorderableTableViewCategory
//
//  Created by jack on 22/6/15.
//  Copyright (c) 2015 Jack Kwong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JKLongPressReorderableTableViewCategory/UITableView+JKLongPressReorderable.h>

@interface JKTableViewController : UITableViewController<UITableViewDataSource, UITableViewDelegate, JKLongPressReorderableDelegate>

@end
