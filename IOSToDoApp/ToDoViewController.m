#import "ToDoViewController.h"
#import "Task.h"
#import "TaskDetailViewController.h"
#import "TaskTableViewCell.h"
#import "SharedUserDefaults.h"

@interface ToDoViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tasksTableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchForTask;

@property (strong, nonatomic) NSMutableArray<Task *> *toDoTasks;
@property (strong, nonatomic) NSMutableArray<Task *> *progressTasks;
@property (strong, nonatomic) NSMutableArray<Task *> *doneTasks;

@property (strong, nonatomic) NSArray<Task *> *filteredTasksArray;

@property (strong,nonatomic)NSMutableArray <Task *>*storedToDoTasks;
@property (strong, nonatomic) NSUserDefaults *defaults;
@property (nonatomic, strong) UIImageView *emptyListImageView;
@property (nonatomic, strong) UIImageView *emptySearchImageView;


@end

@implementation ToDoViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"view will appear");
    self.defaults = [SharedUserDefaults sharedUserDefaults];
    self.storedToDoTasks = [[NSMutableArray alloc] init];
    self.storedToDoTasks = [_defaults objectForKey:@"todoTasks"];
    [self getToDoTasks];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"view did loaded");
    _tasksTableView.delegate = self;
    _tasksTableView.dataSource = self;
    _searchForTask.delegate = self;
    [self configureEmptyListImageView];
    
}

-(void)configureEmptyListImageView {
    // Create and configure the empty list image view
    self.emptyListImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"toDoTasksStarter"]];
    self.emptyListImageView.contentMode = UIViewContentModeScaleAspectFit;

    // Define the new size for the image view
    CGFloat newImageViewWidth = self.tasksTableView.bounds.size.width * 0.7; // Adjust width as needed
    CGFloat newImageViewHeight = self.tasksTableView.bounds.size.height * 0.7; // Adjust height as needed

    // Calculate the center position
    CGFloat imageViewX = (self.tasksTableView.bounds.size.width - newImageViewWidth) / 2.0;
    CGFloat imageViewY = (self.tasksTableView.bounds.size.height - newImageViewHeight) / 4.0;

    // Set the frame of the image view with the new size
    self.emptyListImageView.frame = CGRectMake(imageViewX, imageViewY, newImageViewWidth, newImageViewHeight);

    [self.tasksTableView addSubview:self.emptyListImageView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.searchForTask.text.length > 0) {
        return self.filteredTasksArray.count;
    } else {
        return self.toDoTasks.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    NSArray<Task *> *displayArray = (self.searchForTask.text.length > 0) ? self.filteredTasksArray : self.toDoTasks;
    
    Task *task = displayArray[indexPath.row];
    
    UIImage *image;
    if ([task.priority isEqualToString:@"High"]) {
        image = [UIImage imageNamed:@"high-priority"];
    } else if ([task.priority isEqualToString:@"Low"]) {
        image = [UIImage imageNamed:@"medium-priority"];
    } else {
        image = [UIImage imageNamed:@"low-priority"];
    }
    cell.imageView.image = image;
    
    cell.textLabel.text = task.taskName;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Task *selectedTask = _toDoTasks[indexPath.row];
    TaskDetailViewController *taskDetailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"detail_screen"];
    taskDetailVC.selectedTask = selectedTask;
    taskDetailVC.selectedIndex = indexPath.row;
    taskDetailVC.sourceIdentifier = 1;
    [self.navigationController pushViewController:taskDetailVC animated:YES];
}

- (void)getToDoTasks {
    if (_storedToDoTasks) {
        NSError *unarchiveError = nil;
        NSSet<Class> *allowedClasses = [NSSet setWithArray:@[NSArray.class, Task.class]];
        NSArray<Task *> *retrievedToDoTasks = [NSKeyedUnarchiver unarchivedObjectOfClasses:allowedClasses fromData:_storedToDoTasks error:&unarchiveError];
        
        if (unarchiveError) {
            NSLog(@"Unarchive Error: %@", unarchiveError);
        } else {
            self.toDoTasks = [retrievedToDoTasks mutableCopy];
            [self.tasksTableView reloadData];
            [self checkAndDisplayEmptyListView];
        }
    } else {
        NSLog(@"No data found in UserDefaults for key 'tasksArray'");
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length == 0) {
        self.filteredTasksArray = self.toDoTasks;
    } else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"taskName CONTAINS[cd] %@", searchText];
        self.filteredTasksArray = [self.toDoTasks filteredArrayUsingPredicate:predicate];
    }
    [self.tasksTableView reloadData];
    [self checkAndDisplayEmptyListView];
}

- (void)checkAndDisplayEmptyListView {
    if (self.toDoTasks.count == 0) {
        [self.tasksTableView addSubview:self.emptyListImageView];
        if(self.filteredTasksArray.count==0){
            [self.tasksTableView addSubview:self.emptyListImageView];
        }
    } else {
        [self.emptyListImageView removeFromSuperview];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Delete Task" message:@"Are you sure you want to delete this task?" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        
        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            if (indexPath.row < self.toDoTasks.count) {
                [self.toDoTasks removeObjectAtIndex:indexPath.row];
                
                // Archive updated tasks and store them in UserDefaults
                NSData *updatedToDoTasksData = [NSKeyedArchiver archivedDataWithRootObject:self.toDoTasks requiringSecureCoding:YES error:nil];
                [self.defaults setObject:updatedToDoTasksData forKey:@"todoTasks"];
                
                // Update the table view
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

@end
