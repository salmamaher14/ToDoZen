#import <UIKit/UIKit.h>
#import "Task.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TaskPriority) {
    TaskPriorityLow,
    TaskPriorityMedium,
    TaskPriorityHigh
};

@interface ProgressViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

- (void)filterProgressTasksPariority;

@end

NS_ASSUME_NONNULL_END
