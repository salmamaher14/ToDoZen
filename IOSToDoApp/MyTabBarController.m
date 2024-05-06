//
//  MyTabBarController.m
//  IOSToDoApp
//
//  Created by Salma on 17/04/2024.
//

#import "MyTabBarController.h"
#import "TaskDetailViewController.h"
#import "ProgressViewController.h"
#import "DoneViewController.h"
@interface MyTabBarController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButton;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *filterButton;
@end

@implementation MyTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    
    NSLog(@"in mytabbar");
    _filterButton.hidden = YES;
}


 

- (IBAction)add:(id)sender {
    NSLog(@"pressed");
    TaskDetailViewController *taskDetailVC =[self.storyboard instantiateViewControllerWithIdentifier:@"detail_screen"];
    [self.navigationController pushViewController:taskDetailVC animated:(YES)];
    

}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
        if (viewController == [tabBarController.viewControllers objectAtIndex:0]) {
            _addButton.hidden=NO;
            _filterButton.hidden=YES;
        } else {
        _addButton.hidden=YES;
        _filterButton.hidden=NO;
        

        }
}
- (IBAction)filterTasks:(id)sender {
    // Access the ProgressViewController instance from the tab bar controller
    ProgressViewController *progressVC = (ProgressViewController *)[self.viewControllers objectAtIndex:1]; // Assuming ProgressViewController is at index 1
    
    [progressVC filterProgressTasksPariority];
    
    DoneViewController *doneVC = (DoneViewController *)[self.viewControllers objectAtIndex:2];
    [doneVC filterDoneTasksPariority];


}






@end
