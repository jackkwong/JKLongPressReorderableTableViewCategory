//
//  UITableView+JKLongPressReorderable.m
//  Pods
//
//  Created by jack on 22/6/15.
//
//

#import "UITableView+JKLongPressReorderable.h"
#import <objc/runtime.h>

static char const *ReorderableTagKey = "ReorderableTag";
static char const *LongPressGestureRecognizerTagKey = "LongPressGestureRecognizerTag";

@implementation UITableView (JKLongPressReorderable)

- (void)setReorderable:(BOOL)isReorderable {
  if (self.reorderable == isReorderable) return;
  
  if (isReorderable) {
    
    UILongPressGestureRecognizer *gestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognized:)];
    [self addGestureRecognizer:gestureRecognizer];
    objc_setAssociatedObject(self, LongPressGestureRecognizerTagKey, gestureRecognizer, OBJC_ASSOCIATION_RETAIN);
    
  } else {
    
    UILongPressGestureRecognizer *gestureRecognizer = objc_getAssociatedObject(self, LongPressGestureRecognizerTagKey);
    if (gestureRecognizer != nil) {
      [self removeGestureRecognizer:gestureRecognizer];
      objc_setAssociatedObject(self, LongPressGestureRecognizerTagKey, nil, OBJC_ASSOCIATION_RETAIN);
    }
    
  }
  objc_setAssociatedObject(self, ReorderableTagKey, @(isReorderable), OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)reorderable {
  id reorderable = objc_getAssociatedObject(self, ReorderableTagKey);
  if (reorderable == nil) return false;
  return [reorderable boolValue];
}


- (IBAction)longPressGestureRecognized:(id)sender {
  
  static UIView *snapshot = nil;
  static NSIndexPath *sourceIndexPath = nil;
  
  UILongPressGestureRecognizer *gestureRecognizer = (UILongPressGestureRecognizer *)sender;
  UIGestureRecognizerState state = gestureRecognizer.state;
  
  CGPoint location = [gestureRecognizer locationInView:self];
  NSIndexPath *indexPath = [self indexPathForRowAtPoint:location];
  
  switch (state) {
    case UIGestureRecognizerStateBegan: {
      if (!indexPath || ![self.dataSource tableView:self canMoveRowAtIndexPath:indexPath]){
        // Stop tracking current gesture
        gestureRecognizer.enabled = NO;
        gestureRecognizer.enabled = YES;
        return;
      }
      sourceIndexPath = indexPath;
      
      UITableViewCell *cell = [self cellForRowAtIndexPath:indexPath];
      snapshot = [self createCustomSnapshotFromView:cell];
      
      __block CGPoint center = cell.center;
      snapshot.center = center;
      snapshot.alpha = 0.0;
      [self addSubview:snapshot];
      
      [UIView animateWithDuration:0.25 animations:^{
        center.y = location.y;
        snapshot.center = center;
        snapshot.transform = CGAffineTransformMakeScale(1.05, 1.05);
        snapshot.alpha = 0.98;
        cell.alpha = 0.0;
      } completion:^(BOOL finished) {
        cell.hidden = YES;
      }];
      break;
    }
      
    case UIGestureRecognizerStateChanged: {
      CGPoint center = snapshot.center;
      center.y = location.y;
      snapshot.center = center;
      
      if (!indexPath || [indexPath isEqual:sourceIndexPath]) return;
      indexPath = [self.delegate tableView:self targetIndexPathForMoveFromRowAtIndexPath:sourceIndexPath toProposedIndexPath:indexPath];
      if (!indexPath || [indexPath isEqual:sourceIndexPath]) return;
      
      [self.dataSource tableView:self moveRowAtIndexPath:sourceIndexPath toIndexPath:indexPath];
      [self moveRowAtIndexPath:sourceIndexPath toIndexPath:indexPath];
      
      sourceIndexPath = indexPath;
      break;
    }
      
    default: {
      // Clean up
      UITableViewCell *cell = [self cellForRowAtIndexPath:sourceIndexPath];
      cell.hidden = NO;
      cell.alpha = 0.0;
      
      [UIView animateWithDuration:0.25 animations:^{
        snapshot.center = cell.center;
        snapshot.transform = CGAffineTransformIdentity;
        snapshot.alpha = 0.0;
        cell.alpha = 1.0;
      } completion:^(BOOL finished) {
        sourceIndexPath = nil;
        [snapshot removeFromSuperview];
        snapshot = nil;
        [( (id<JKLongPressReorderableDelegate>) self.delegate ) didFinishReorderingTableview:self];
      }];
      
      break;
    }
  }
}

#pragma mark - Helper methods

- (UIView *)createCustomSnapshotFromView:(UIView *)inputView {
  
  UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, NO, 0);
  [inputView.layer renderInContext:UIGraphicsGetCurrentContext()];
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  UIView *snapshot = [[UIImageView alloc] initWithImage:image];
  snapshot.layer.masksToBounds = NO;
  snapshot.layer.cornerRadius = 0.0;
  snapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0);
  snapshot.layer.shadowRadius = 5.0;
  snapshot.layer.shadowOpacity = 0.4;
  
  return snapshot;
}

@end
