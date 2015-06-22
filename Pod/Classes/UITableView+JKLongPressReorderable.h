//
//  UITableView+JKLongPressReorderable.h
//  Pods
//
//  Created by jack on 22/6/15.
//
//

#import <UIKit/UIKit.h>

@protocol JKLongPressReorderableDelegate <NSObject>
-(void) didFinishReorderingTableview:(UITableView *)tableView;
@end

@interface UITableView (JKLongPressReorderable)
-(void) setReorderable:(BOOL)isReorderable;
-(BOOL) reorderable;
@end
