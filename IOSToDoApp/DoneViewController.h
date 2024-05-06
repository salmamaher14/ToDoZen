//
//  DoneViewController.h
//  IOSToDoApp
//
//  Created by Salma on 02/05/2024.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DoneViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>
- (void)filterDoneTasksPariority ;

@end

NS_ASSUME_NONNULL_END
