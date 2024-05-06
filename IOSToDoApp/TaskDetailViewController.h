//
//  TaskDetailViewController.h
//  IOSToDoApp
//
//  Created by Salma on 17/04/2024.
//

#import "ViewController.h"
#import "Task.h"

NS_ASSUME_NONNULL_BEGIN

@interface TaskDetailViewController : UIViewController
@property (nonatomic, strong) Task *selectedTask;
@property (nonatomic, assign) NSInteger sourceIdentifier;
@property (nonatomic, assign) NSInteger selectedIndex;

-(void)showAlertWithTitle:(NSString *)title message:(NSString *)message;

@end

NS_ASSUME_NONNULL_END
