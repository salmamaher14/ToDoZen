//
//  DoneViewController.m
//  IOSToDoApp
//
//  Created by Salma on 02/05/2024.
//

#import "DoneViewController.h"

#import "ProgressViewController.h"
#import "SharedUserDefaults.h"
#import "TaskDetailViewController.h"

@interface DoneViewController ()

@property (weak, nonatomic) IBOutlet UITableView *doneTableView;

@property (strong, nonatomic) NSMutableArray<Task *> *doneTasksArray;
@property (strong, nonatomic) NSMutableArray<Task *> *storedDoneTasksArray;
@property (strong, nonatomic) NSUserDefaults *defaults;
@property (weak, nonatomic) IBOutlet UISearchBar *doneSearch;
@property (strong, nonatomic) NSArray<Task *> *filteredTasksArray;
@property NSMutableArray<Task *> *lowPriorityTasks;
@property NSMutableArray<Task *> *mediumPriorityTasks;
@property NSMutableArray<Task *> *highPriorityTasks;
@property (nonatomic, strong) UIImageView *emptyListImageView;
@property BOOL makeFilter;
@property int numberOfSections;


@end

@implementation DoneViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    _numberOfSections=1;
    _makeFilter=false;
    self.defaults = [SharedUserDefaults sharedUserDefaults];
    self.storedDoneTasksArray = [NSMutableArray<Task *> new];
    self.storedDoneTasksArray = [_defaults objectForKey:@"doneTasks"];
    _lowPriorityTasks=[NSMutableArray new];
    _mediumPriorityTasks=[NSMutableArray new];
    _highPriorityTasks=[NSMutableArray new];
    [self getDoneTasks];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.doneTableView.delegate = self;
    self.doneTableView.dataSource = self;
    _doneSearch.delegate=self;
    [self configureEmptyListImageView];


}
-(void)configureEmptyListImageView {
    // Create and configure the empty list image view
    self.emptyListImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"doneTasksStarter"]];
    self.emptyListImageView.contentMode = UIViewContentModeScaleAspectFit;

    // Define the new size for the image view
    CGFloat newImageViewWidth = self.doneTableView.bounds.size.width * 0.6; // Adjust width as needed
    CGFloat newImageViewHeight = self.doneTableView.bounds.size.height * 0.6; // Adjust height as needed

    // Calculate the center position
    CGFloat imageViewX = (self.doneTableView.bounds.size.width - newImageViewWidth) / 2.0;
    CGFloat imageViewY = (self.doneTableView.bounds.size.height - newImageViewHeight) / 4.0;

    // Set the frame of the image view with the new size
    self.emptyListImageView.frame = CGRectMake(imageViewX, imageViewY, newImageViewWidth, newImageViewHeight);

    [self.doneTableView addSubview:self.emptyListImageView];
}

- (void)checkAndDisplayEmptyListView {
    if (self.doneTasksArray.count == 0) {
        NSLog(@"yer");
        [self.doneTableView addSubview:self.emptyListImageView];
    } else {
        [self.emptyListImageView removeFromSuperview];
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Task *selectedTask=_doneTasksArray[indexPath.row];
    
    TaskDetailViewController *taskDetailVC =[self.storyboard instantiateViewControllerWithIdentifier:@"detail_screen"];
    
     taskDetailVC.selectedTask=selectedTask;
     taskDetailVC.selectedIndex = indexPath.row;
    NSLog(@"index path %d",taskDetailVC.selectedIndex);
     taskDetailVC.sourceIdentifier = 3;

    [self.navigationController pushViewController:taskDetailVC animated:(YES)];
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.doneSearch.text.length > 0) {
        return self.filteredTasksArray.count;
    } else {
        if (_makeFilter) {
            // If filtering is applied
            switch (section) {
                case 0: // Low Priority
                    return _lowPriorityTasks.count;
                case 1: // Medium Priority
                    return _mediumPriorityTasks.count;
                case 2: // High Priority
                    return _highPriorityTasks.count;
                default:
                    return 0;
            }
        } else {
            
            return self.doneTasksArray.count;
        }
    }
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (_makeFilter) {
        // If filtering is applied
        switch (section) {
            case 0: // Low Priority
                if(_lowPriorityTasks.count!=0){
                    return @"Low Priority";
                }
                break; // Add break statement here
            case 1: // Medium Priority
                if(_mediumPriorityTasks.count!=0){
                    return @"Medium Priority";
                }
                break; // Add break statement here
            case 2: // High Priority
                if(_highPriorityTasks.count!=0){
                    return @"High Priority";
                }
                break; // Add break statement here
            default:
                return @"";
        }
    } else {
        return @"";
    }
    return @"";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger numberOfSections;
    if (self.makeFilter) {
        numberOfSections = self.numberOfSections;
    } else {
        numberOfSections = 1;
    }

    return numberOfSections;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"done_cell" forIndexPath:indexPath];
    
    NSArray<Task *> *displayArray;
    if (self.doneSearch.text.length > 0) {
        // If search is active, use filteredTasksArray
        displayArray = self.filteredTasksArray;
    } else if (_makeFilter) {
        NSLog(@"number of sections %d",indexPath.section);
        // If filtering is applied, use priority-specific arrays based on section
        switch (indexPath.section) {
            case 0: // Low Priority
                displayArray = self.lowPriorityTasks;
                NSLog(@"case 0");
                break;
            case 1: // Medium Priority
                displayArray = self.mediumPriorityTasks;
                NSLog(@"case 1");


                break;
            case 2: // High Priority
                displayArray = self.highPriorityTasks;
                NSLog(@"case 2");
                break;
            default:
                break;
        }
    } else {
        // If neither search nor filtering is applied, use the default progressTasksArray
        displayArray = self.doneTasksArray;
    }
    
    Task *task = displayArray[indexPath.row];
    NSLog(@"task %@",task.taskName);
    
    UIImage *image;
    if ([task.priority isEqualToString:@"High"]) {
        image = [UIImage imageNamed:@"high-priority"];
    } else if ([task.priority isEqualToString:@"Medium"]) {
        image = [UIImage imageNamed:@"medium-priority"];
    } else {
        image = [UIImage imageNamed:@"low-priority"];
    }
    cell.imageView.image = image;
    
    cell.textLabel.text = task.taskName;
    return cell;
}


- (void)getDoneTasks {
    if (_storedDoneTasksArray) {
        NSLog(@"yess");
        NSError *unarchiveError = nil;
        NSSet<Class> *allowedClasses = [NSSet setWithArray:@[NSArray.class, Task.class]];
        NSArray<Task *> *retrievedDoneTasks = [NSKeyedUnarchiver unarchivedObjectOfClasses:allowedClasses fromData:_storedDoneTasksArray error:&unarchiveError];
        
        if (unarchiveError) {
            NSLog(@"Unarchive Error: %@", unarchiveError);
        } else {
        
            self.doneTasksArray = [retrievedDoneTasks mutableCopy];
            [self.doneTableView reloadData];
            [self checkAndDisplayEmptyListView];
        }
    } else {
        NSLog(@"No data found in UserDefaults for key 'tasksArray'");
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    if (searchText.length == 0) {
      
        self.filteredTasksArray = self.doneTasksArray;
    } else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"taskName CONTAINS[cd] %@", searchText];
        self.filteredTasksArray = [self.doneTasksArray filteredArrayUsingPredicate:predicate];
    }
 
    
    [self.doneTableView reloadData];
    [self checkAndDisplayEmptyListView];

    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Delete Task" message:@"Are you sure you want to delete this task?" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        
        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            if (indexPath.row < self.doneTasksArray.count) {
                [self.doneTasksArray removeObjectAtIndex:indexPath.row];
                
                NSData *updatedDoneTasksData = [NSKeyedArchiver archivedDataWithRootObject:self.doneTasksArray requiringSecureCoding:YES error:nil];
                [self.defaults setObject:updatedDoneTasksData forKey:@"doneTasks"];
                
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                [self checkAndDisplayEmptyListView];
            } else {
                NSLog(@"Attempted to delete task at invalid indexPath %ld", (long)indexPath.row);
            }
        }];
        
        [alertController addAction:cancelAction];
        [alertController addAction:deleteAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
}


- (void)filterDoneTasksPariority {

    _numberOfSections = 3;
    _makeFilter = true;

    [_lowPriorityTasks removeAllObjects];
    [_mediumPriorityTasks removeAllObjects];
    [_highPriorityTasks removeAllObjects];
      
    for (Task *task in self.doneTasksArray) {
        if ([task.priority isEqualToString:@"Low"]) {
            [_lowPriorityTasks addObject:task];
        } else if ([task.priority isEqualToString:@"Medium"]) {
            [_mediumPriorityTasks addObject:task];
        } else if ([task.priority isEqualToString:@"High"]) {
            [_highPriorityTasks addObject:task];
        }
    }
    [_doneTableView reloadData];
}

@end
