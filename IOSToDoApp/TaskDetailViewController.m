#import "TaskDetailViewController.h"
#import "Task.h"
#import "SharedUserDefaults.h"
#import "SVGKit.h"

@interface TaskDetailViewController ()

@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextView *taskDescription;
@property (weak, nonatomic) IBOutlet UISegmentedControl *pariority;
@property (weak, nonatomic) IBOutlet UISegmentedControl *state;
@property (weak, nonatomic) IBOutlet UIDatePicker *taskDate;
@property (weak, nonatomic) IBOutlet UIButton *btnAdd;
@property (weak, nonatomic) IBOutlet UIImageView *taskStateImageView;

@property (nonatomic,strong)NSMutableArray<Task *> *todoTasks;
@property (nonatomic,strong)NSMutableArray<Task *> *progressTasks;
@property (nonatomic,strong)NSMutableArray<Task *> *doneTasks;
@property(nonatomic,strong) NSMutableArray *storedProgressTasks;
@property (nonatomic,strong)NSMutableArray *storedToDoTasks ;
@property (nonatomic,strong)NSMutableArray *storedDoneTasks ;
@property (nonatomic, strong) NSUserDefaults *defaults;

@end

@implementation TaskDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureDatePicker];
    _defaults=[SharedUserDefaults sharedUserDefaults];
    [self.state setEnabled:NO forSegmentAtIndex:1];
    [self.state setEnabled:NO forSegmentAtIndex:2];
    [self configureUI];
}

- (void)configureDatePicker {
    // Set minimum date to the current date and time
    self.taskDate.minimumDate = [NSDate date];
  
}



- (void)configureUI {
    if (self.sourceIdentifier == 1 || self.sourceIdentifier==2 || self.sourceIdentifier==3) {
        
        [self.btnAdd setTitle:@"Edit" forState:UIControlStateNormal];
        [self.state setEnabled:YES forSegmentAtIndex:1];
        [self.state setEnabled:YES forSegmentAtIndex:2];
        [self handleTaskType];
    } else {
        [self handleAddAction];
    }
}
- (void)handleTaskType {
    if(self.sourceIdentifier == 1) {
   
        SVGKImage *svgImage = [SVGKImage imageNamed:@"addTask"];
        self.taskStateImageView.image = svgImage.UIImage;

        [self retrieveToDoTasks];
    } else if(self.sourceIdentifier == 2) {
        SVGKImage *svgImage = [SVGKImage imageNamed:@"download-3"];
        self.taskStateImageView.image = svgImage.UIImage;
        [self retrieveProgressTasks];
    } else {
        SVGKImage *svgImage = [SVGKImage imageNamed:@"download"];
        self.taskStateImageView.image = svgImage.UIImage;

        [self retrieveDoneTasks];
    }
}



- (void)retrieveTasksWithKey:(NSString *)key title:(NSString *)title {
    self.navigationItem.title = title;
    NSData *storedTasksData = [self.defaults objectForKey:key];
    
    if (storedTasksData) {
        NSError *unarchiveError = nil;
        NSSet<Class> *allowedClasses = [NSSet setWithArray:@[NSArray.class, Task.class]];
        NSArray<Task *> *tasks = [NSKeyedUnarchiver unarchivedObjectOfClasses:allowedClasses fromData:storedTasksData error:&unarchiveError];
        
        if (tasks && tasks.count > self.selectedIndex) {
            Task *selectedTask = tasks[self.selectedIndex];
            [self setFormDataWithTask:selectedTask];
        }
    } else {
        NSLog(@"No data found in UserDefaults for key %@", key);
    }
}

- (void)setFormDataWithTask:(Task *)task {
    [self.name setText:task.taskName];
    NSLog(@"selected name is %@", task.taskName);
    [self.taskDescription setText:task.taskDescription];
    NSInteger priorityIndex = [self getIndexOfPariority:task.priority];
    [self.pariority setSelectedSegmentIndex:priorityIndex];
    NSInteger stateIndex = [self getStateIndex:task.state];
    [self.state setSelectedSegmentIndex:stateIndex];
    [self.taskDate setDate:task.taskDate animated:YES];
    [self.btnAdd setTitle:@"Edit" forState:UIControlStateNormal];
}

- (void)retrieveToDoTasks {
    [self retrieveTasksWithKey:@"todoTasks" title:@""];
}

- (void)retrieveProgressTasks {
    [self retrieveTasksWithKey:@"progressTasks" title:@""];
}

- (void)retrieveDoneTasks {
    [self retrieveTasksWithKey:@"doneTasks" title:@""];
}



- (void)handleAddAction {
    //self.navigationItem.title = @"Add Task";
    [self.btnAdd setTitle:@"Add" forState:UIControlStateNormal];
    SVGKImage *svgImage = [SVGKImage imageNamed:@"addTask"];
    self.taskStateImageView.image = svgImage.UIImage;
}

- (NSInteger)getIndexOfPariority:(NSString *)priority {
    if ([priority isEqualToString:@"Low"]) {
        return 0;
    } else if ([priority isEqualToString:@"Medium"]) {
        return 1;
    } else {
        return 2;
    }
}

- (NSInteger)getStateIndex:(NSString *)state {
    if ([state isEqualToString:@"todo"]) {
        return 0;
    } else if ([state isEqualToString:@"In Progress"]) {
        return 1;
    } else {
        return 2;
    }
}

- (IBAction)addAction:(id)sender {
    NSString *taskName = self.name.text;
    NSString *taskDescription = self.taskDescription.text;
    NSString *priority = [self.pariority titleForSegmentAtIndex:self.pariority.selectedSegmentIndex];
    NSString *state = [self.state titleForSegmentAtIndex:self.state.selectedSegmentIndex];
    NSDate *taskDate = self.taskDate.date;

    if ([taskName isEqualToString:@""] || [taskDescription isEqualToString:@""]) {
        [self showAlertWithTitle:@"Missing Information" message:@"Please enter task name and description."];
        return;
    }

    Task *task = [[Task alloc] initWithName:taskName priority:priority taskDescription:taskDescription state:state date:taskDate];
    NSString *confirmationMessage = @"Are you sure you want to save this task?";
    [self showAlertWithTitle:@"Confirmation" message:confirmationMessage task:task];
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message task:(Task *)task {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    
    UIAlertAction *addAction = [UIAlertAction actionWithTitle:@"OK"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           [self handleAddOrEditActionForTask:task];
                                                       }];
    
    [alert addAction:cancelAction];
    [alert addAction:addAction];
    [self presentViewController:alert animated:YES completion:nil];
}


- (void)handleAddOrEditActionForTask:(Task *)task {
    if (self.sourceIdentifier == 1 || self.sourceIdentifier == 2) {
        [self editTask:task];
    } else {
        [self addTaskTotoDo:task];
    }
}

- (void)editTaskForProgress:(Task*)task :(NSUInteger)index{
    
        NSData *storedProgressTasksData = [self.defaults objectForKey:@"progressTasks"];
        if (storedProgressTasksData) {
         NSError *unarchiveError = nil;
            
        NSSet<Class> *allowedClasses = [NSSet setWithArray:@[NSArray.class, Task.class]];
            _storedProgressTasks = [NSKeyedUnarchiver unarchivedObjectOfClasses:allowedClasses fromData:storedProgressTasksData error:&unarchiveError];
            
            [_storedProgressTasks replaceObjectAtIndex:index withObject:task];
                   
            if ([task.state isEqualToString:@"Done"]) {
               [_storedProgressTasks removeObjectAtIndex:index];
               [self addTaskToDone:task];
            }
            NSData *updatedProgressTasksData = [NSKeyedArchiver archivedDataWithRootObject:_storedProgressTasks requiringSecureCoding:YES error:nil];
            [self.defaults setObject:updatedProgressTasksData forKey:@"progressTasks"];
            [self.navigationController popViewControllerAnimated:YES];
        }
}

- (void)editTaskForDone:(Task *)task :(NSUInteger) index{
    NSData *storedDoneTasksData = [self.defaults objectForKey:@"doneTasks"];
    
    if (storedDoneTasksData) {
     NSError *unarchiveError = nil;
        
        NSSet<Class> *allowedClasses = [NSSet setWithArray:@[NSArray.class, Task.class]];
        _storedDoneTasks = [NSKeyedUnarchiver unarchivedObjectOfClasses:allowedClasses fromData:storedDoneTasksData error:&unarchiveError];
        
        [_storedDoneTasks replaceObjectAtIndex:index withObject:task];
               

        NSData *updatedProgressTasksData = [NSKeyedArchiver archivedDataWithRootObject:_storedProgressTasks requiringSecureCoding:YES error:nil];
        [self.defaults setObject:updatedProgressTasksData forKey:@"doneTasks"];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)editTaskForToDo:(Task *)task :(NSUInteger) index{
    NSLog(@"index nnnn %lu",(unsigned long)index);

    NSData *storedToDoTasksData = [self.defaults objectForKey:@"todoTasks"];
    
    if (storedToDoTasksData) {
        NSError *unarchiveError = nil;
        
        NSSet<Class> *allowedClasses = [NSSet setWithArray:@[NSArray.class, Task.class]];
        _storedToDoTasks = [NSKeyedUnarchiver unarchivedObjectOfClasses:allowedClasses fromData:storedToDoTasksData error:&unarchiveError];
        
        
              if ([task.state isEqualToString:@"In Progress"]) {
                  NSLog(@"progggg %lu",(unsigned long)index);

                  [_storedToDoTasks removeObjectAtIndex:index];
                  
                  NSLog(@"taskname %@", task.taskName);
                  [self addTaskToProgress:task];
              } else if ([task.state isEqualToString:@"Done"]) {
                  [_storedToDoTasks removeObjectAtIndex:index];
                  [self addTaskToDone:task];
              } else {
                  // Replace the task at the selected index with the new task
                  NSLog(@"storedtodotasks %@",_storedToDoTasks[0]);

                  [_storedToDoTasks replaceObjectAtIndex:index withObject:task];
              }
              
              // Archive the updated ToDo list and store it in UserDefaults
              NSData *updatedToDoTasksData = [NSKeyedArchiver archivedDataWithRootObject:_storedToDoTasks requiringSecureCoding:YES error:nil];
              [self.defaults setObject:updatedToDoTasksData forKey:@"todoTasks"];
        [self.navigationController popViewControllerAnimated:YES];
        
    }
}

- (void)editTask:(Task *)task {
   NSUInteger index = self.selectedIndex;
    if (index != NSNotFound) {
        switch (self.sourceIdentifier) {
            case 2:
                [self editTaskForProgress:task :index];
                break;
            case 3:
                [self editTaskForDone:task :index];
                break;
            default:
                [self editTaskForToDo:task :index];
                break;
        }
    } else {
        NSLog(@"Invalid selected index");
    }
}

 
- (void)showAlert:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}


- (void)addTask:(Task *)task toTasksWithKey:(NSString *)tasksKey {
    NSMutableArray<Task *> *taskList = [NSMutableArray<Task *> new];
    NSData *storedTasksData = [self.defaults objectForKey:tasksKey];

    if (storedTasksData) {
        NSError *unarchiveError = nil;
        NSSet<Class> *allowedClasses = [NSSet setWithArray:@[NSArray.class, Task.class]];
        NSArray<Task *> *existingTasks = [NSKeyedUnarchiver unarchivedObjectOfClasses:allowedClasses fromData:storedTasksData error:&unarchiveError];

        if (existingTasks) {
            [taskList addObjectsFromArray:existingTasks];
        } else {
            NSLog(@"Error unarchiving existing tasks: %@", unarchiveError);
        }
    }

    [taskList addObject:task];

    NSError *archiveError = nil;
    NSData *archiveData = [NSKeyedArchiver archivedDataWithRootObject:taskList requiringSecureCoding:YES error:&archiveError];

    if (archiveData) {
        [self.defaults setObject:archiveData forKey:tasksKey];
        NSLog(@"Updated tasks saved to UserDefaults for key: %@", tasksKey);
    } else {
        NSLog(@"Error archiving updated tasks for key %@: %@", tasksKey, archiveError);
    }
}

- (void)addTaskTotoDo:(Task *)task {
    [self addTask:task toTasksWithKey:@"todoTasks"];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addTaskToProgress:(Task *)task {
    [self addTask:task toTasksWithKey:@"progressTasks"];
}

- (void)addTaskToDone:(Task *)task {
    [self addTask:task toTasksWithKey:@"doneTasks"];
}
 


- (void)showAlertWithTitle:(nonnull NSString *)title message:(nonnull NSString *)message {
}

@end






/*
 
 
 #import "TaskDetailViewController.h"
 #import "Task.h"
 #import "SharedUserDefaults.h"

 @interface TaskDetailViewController ()

 @property (weak, nonatomic) IBOutlet UITextField *name;
 @property (weak, nonatomic) IBOutlet UITextField *taskDescription;
 @property (weak, nonatomic) IBOutlet UISegmentedControl *pariority;
 @property (weak, nonatomic) IBOutlet UISegmentedControl *state;
 @property (weak, nonatomic) IBOutlet UIDatePicker *taskDate;
 @property (weak, nonatomic) IBOutlet UIButton *btnAdd;
 @property (nonatomic,strong)NSMutableArray<Task *> *todoTasks;
 @property (nonatomic,strong)NSMutableArray<Task *> *progressTasks;
 @property (nonatomic,strong)NSMutableArray<Task *> *doneTasks;
 @property(nonatomic,strong) NSMutableArray *storedProgressTasks;
 @property (nonatomic,strong)NSMutableArray *storedToDoTasks ;
 @property (nonatomic,strong)NSMutableArray *storedDoneTasks ;
 @property (nonatomic, strong) NSUserDefaults *defaults;

 @end

 @implementation TaskDetailViewController

 - (void)viewDidLoad {
     [super viewDidLoad];
     _defaults=[SharedUserDefaults sharedUserDefaults];
     [self.state setEnabled:NO forSegmentAtIndex:1];
     [self.state setEnabled:NO forSegmentAtIndex:2];
     [self configureUI];
 }

 - (void)configureUI {
     if (self.sourceIdentifier == 1 || self.sourceIdentifier==2) {
         
         [self.btnAdd setTitle:@"Edit" forState:UIControlStateNormal];
         [self.state setEnabled:YES forSegmentAtIndex:1];
         [self.state setEnabled:YES forSegmentAtIndex:2];
         [self handleTaskType];
     } else {
         [self handleAddAction];
     }
 }

 - (void)handleTaskType {
     if(self.sourceIdentifier==1){
         [self retrieveToDoTasks];
     }else if(self.sourceIdentifier==2){
         [self retrieveProgressTasks];
     }
     
 }

 -(void)retrieveToDoTasks {
     
     self.navigationItem.title = @"Edit Task";
     NSLog(@"selected index is:%ld", (long)self.selectedIndex);
     
   
     NSData *storedToDoTasksData = [self.defaults objectForKey:@"todoTasks"];
     
     if (storedToDoTasksData) {
         NSError *unarchiveError = nil;
         NSSet<Class> *allowedClasses = [NSSet setWithArray:@[NSArray.class, Task.class]];
         NSArray<Task *> *storedToDoTasks = [NSKeyedUnarchiver unarchivedObjectOfClasses:allowedClasses fromData:storedToDoTasksData error:&unarchiveError];
         
         Task *selectedTask = storedToDoTasks[self.selectedIndex];
         [self.name setText:selectedTask.taskName];
         NSLog(@"selected name is %@", selectedTask.taskName);
         [self.taskDescription setText:selectedTask.taskDescription];
         NSInteger priorityIndex = [self getIndexOfPariority:selectedTask.priority];
         [self.pariority setSelectedSegmentIndex:priorityIndex];
         NSInteger stateIndex = [self getStateIndex:selectedTask.state];
         [self.state setSelectedSegmentIndex:stateIndex];
         [self.taskDate setDate:selectedTask.taskDate animated:YES];
         [self.btnAdd setTitle:@"Edit" forState:UIControlStateNormal];
     } else {
         NSLog(@"No data found in UserDefaults for key 'todoTasks'");
     }
     
 }

 -(void) retrieveProgressTasks {
     
     self.navigationItem.title = @"Edit Task progress";
     NSData *storedProgressTasksData = [self.defaults objectForKey:@"progressTasks"];
     
     if (storedProgressTasksData) {
         NSError *unarchiveError = nil;
         NSSet<Class> *allowedClasses = [NSSet setWithArray:@[NSArray.class, Task.class]];
         NSArray<Task *> *unArchivedProgressTasks = [NSKeyedUnarchiver unarchivedObjectOfClasses:allowedClasses fromData:storedProgressTasksData error:&unarchiveError];
         
         Task *selectedTask = unArchivedProgressTasks[self.selectedIndex];
         [self.name setText:selectedTask.taskName];
         NSLog(@"selected name is %@", selectedTask.taskName);
         [self.taskDescription setText:selectedTask.taskDescription];
         NSInteger priorityIndex = [self getIndexOfPariority:selectedTask.priority];
         [self.pariority setSelectedSegmentIndex:priorityIndex];
         NSInteger stateIndex = [self getStateIndex:selectedTask.state];
         [self.state setSelectedSegmentIndex:stateIndex];
         [self.taskDate setDate:selectedTask.taskDate animated:YES];
         [self.btnAdd setTitle:@"Edit" forState:UIControlStateNormal];
     } else {
         NSLog(@"No data found in UserDefaults for key 'progress tasks'");
     }
 }


 -(void) retrieveDoneTasks {
     
     self.navigationItem.title = @"Done Tasks";
     NSData *storedDoneTasksData = [self.defaults objectForKey:@"doneTasks"];
     
     if (storedDoneTasksData) {
         NSError *unarchiveError = nil;
         NSSet<Class> *allowedClasses = [NSSet setWithArray:@[NSArray.class, Task.class]];
         NSArray<Task *> *unArchivedDoneTasks = [NSKeyedUnarchiver unarchivedObjectOfClasses:allowedClasses fromData:storedDoneTasksData error:&unarchiveError];
         
         Task *selectedTask = unArchivedDoneTasks[self.selectedIndex];
      
     } else {
         NSLog(@"No data found in UserDefaults for key 'progress tasks'");
     }
 }





 - (void)handleAddAction {
     self.navigationItem.title = @"Add Task";
     [self.btnAdd setTitle:@"Add" forState:UIControlStateNormal];
 }




 - (NSInteger)getIndexOfPariority:(NSString *)priority {
     if ([priority isEqualToString:@"Low"]) {
         return 0;
     } else if ([priority isEqualToString:@"Medium"]) {
         return 1;
     } else {
         return 2;
     }
 }




 - (NSInteger)getStateIndex:(NSString *)state {
     if ([state isEqualToString:@"todo"]) {
         return 0;
     } else if ([state isEqualToString:@"In Progress"]) {
         return 1;
     } else {
         return 2;
     }
 }




 - (IBAction)addAction:(id)sender {
     
     
     NSString *taskName = self.name.text;
     NSString *taskDescription = self.taskDescription.text;
     NSString *priority = [self.pariority titleForSegmentAtIndex:self.pariority.selectedSegmentIndex];
     NSString *state = [self.state titleForSegmentAtIndex:self.state.selectedSegmentIndex];
     NSDate *taskDate = self.taskDate.date;

     if ([taskName isEqualToString:@""] || [taskDescription isEqualToString:@""]) {
         [self showAlert:@"Missing Information" message:@"Please enter task name and description."];
         return;
     }

     Task *task = [Task new];
     task.taskName = taskName;
     task.taskDescription = taskDescription;
     task.priority = priority;
     task.state = state;
     task.taskDate = taskDate;

     UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Confirmation"
                                                                    message:@"Are you sure you want to save this task?"
                                                             preferredStyle:UIAlertControllerStyleAlert];

     UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                            style:UIAlertActionStyleCancel
                                                          handler:nil];

     UIAlertAction *addAction = [UIAlertAction actionWithTitle:@"OK"
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * _Nonnull action) {
                                                            if (self.sourceIdentifier == 1 || self.sourceIdentifier==2) {
                                                                [self editTask:task];
                                                            } else {
                                                                [self addTaskTotoDo:task ];
                                                            }
                                                        }];
     
     [alert addAction:cancelAction];
     [alert addAction:addAction];
     [self presentViewController:alert animated:YES completion:^{
         

     }];
     

 }

 - (void)editTask:(Task *)task {
     NSLog(@"edit task%@", task.taskName);
     
     NSData *storedToDoTasksData = [self.defaults objectForKey:@"todoTasks"];
     
     if (storedToDoTasksData) {
         NSError *unarchiveError = nil;
         
         NSSet<Class> *allowedClasses = [NSSet setWithArray:@[NSArray.class, Task.class]];
         _storedToDoTasks = [NSKeyedUnarchiver unarchivedObjectOfClasses:allowedClasses fromData:storedToDoTasksData error:&unarchiveError];
         
         NSUInteger index = self.selectedIndex;
         
         if (index != NSNotFound) {
             if (self.sourceIdentifier == 2) {
                 // Update the stored progress with the task
                 NSData *storedProgressTasksData = [self.defaults objectForKey:@"progressTasks"];
                 
                 
                 if (storedProgressTasksData) {
                     
                     NSError *unarchiveError = nil;
                     
                     NSSet<Class> *allowedClasses = [NSSet setWithArray:@[NSArray.class, Task.class]];
                     _storedProgressTasks = [NSKeyedUnarchiver unarchivedObjectOfClasses:allowedClasses fromData:storedProgressTasksData error:&unarchiveError];
                     
                     
                     [_storedProgressTasks replaceObjectAtIndex:index withObject:task];
                 
                 // Archive the updated progress tasks and store it in UserDefaults
                 NSData *updatedProgressTasksData = [NSKeyedArchiver archivedDataWithRootObject:_storedProgressTasks requiringSecureCoding:YES error:nil];
                 [self.defaults setObject:updatedProgressTasksData forKey:@"progressTasks"];
                 
                 // Log the updated progress tasks array
                 NSLog(@"Updated Progress Tasks: %@", _storedProgressTasks);
                     
                     
                 }
                   
             } else {
                 NSLog(@"in else");
                 // Remove the task if it's in progress or done
                 if ([task.state isEqualToString:@"In Progress"]) {
                     [_storedToDoTasks removeObjectAtIndex:index];
                     
                     NSLog(@"taskname %@", task.taskName);
                     [self addTaskToProgress:task];
                 } else if ([task.state isEqualToString:@"Done"]) {
                     [_storedToDoTasks removeObjectAtIndex:index];
                     [self addTaskToDone:task];
                 } else {
                     // Replace the task at the selected index with the new task
                     NSLog(@"storedtodotasks %@",_storedToDoTasks[0]);

                     [_storedToDoTasks replaceObjectAtIndex:index withObject:task];
                 }
                 
                 // Archive the updated ToDo list and store it in UserDefaults
                 NSData *updatedToDoTasksData = [NSKeyedArchiver archivedDataWithRootObject:_storedToDoTasks requiringSecureCoding:YES error:nil];
                 [self.defaults setObject:updatedToDoTasksData forKey:@"todoTasks"];
             }
         } else {
             NSLog(@"Task %@ not found in 'todoTasks' array or invalid selected index.", task.taskName);
         }
     } else {
         NSLog(@"No data found in UserDefaults for key 'todoTasks'");
     }
 }



 - (void)showAlert:(NSString *)title message:(NSString *)message {
     UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                    message:message
                                                             preferredStyle:UIAlertControllerStyleAlert];
     
     UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                        style:UIAlertActionStyleDefault
                                                      handler:nil];
     [alert addAction:okAction];
     [self presentViewController:alert animated:YES completion:nil];
 }




 - (void)addTaskTotoDo:(Task *)task {
     NSLog(@"here in addtodo");
    
     self.storedToDoTasks = [self.defaults objectForKey:@"todoTasks"];
     self.todoTasks = [NSMutableArray<Task *> new];

     if (self.storedToDoTasks) {
         NSError *unarchiveError = nil;
         NSSet<Class> *allowedClasses = [NSSet setWithArray:@[NSArray.class, Task.class]];
         NSArray<Task *> *existingToDoTasks = [NSKeyedUnarchiver unarchivedObjectOfClasses:allowedClasses fromData:self.storedToDoTasks error:&unarchiveError];
         
         if (existingToDoTasks) {
             [self.todoTasks addObjectsFromArray:existingToDoTasks];
         } else {
             NSLog(@"Error unarchiving existing to-do tasks: %@", unarchiveError);
         }
     }
     [self.todoTasks addObject:task];


     NSError *archiveError = nil;
     NSData *archiveData = [NSKeyedArchiver archivedDataWithRootObject:self.todoTasks requiringSecureCoding:YES error:&archiveError];
     
     if (archiveData) {
         [self.defaults setObject:archiveData forKey:@"todoTasks"];
         NSLog(@"Updated to-do tasks saved to UserDefaults");
     } else {
         NSLog(@"Error archiving updated to-do tasks: %@", archiveError);
     }
     

 }




 - (void)addTaskToProgress:(Task *)task {
     
     
     self.storedProgressTasks = [self.defaults objectForKey:@"progressTasks"];
     self.progressTasks = [NSMutableArray<Task *> new];

     if (self.storedProgressTasks) {
         NSError *unarchiveError = nil;
         NSSet<Class> *allowedClasses = [NSSet setWithArray:@[NSArray.class, Task.class]];
         NSArray<Task *> *unArchiveProgressTasks = [NSKeyedUnarchiver unarchivedObjectOfClasses:allowedClasses fromData:self.storedProgressTasks error:&unarchiveError];
         
         if (unArchiveProgressTasks) {
             [self.progressTasks addObjectsFromArray:unArchiveProgressTasks];
         } else {
             NSLog(@"Error unarchiving existing progress tasks: %@", unarchiveError);
         }
     }
     [self.progressTasks addObject:task];


     NSError *archiveError = nil;
     NSData *archiveData = [NSKeyedArchiver archivedDataWithRootObject:self.progressTasks requiringSecureCoding:YES error:&archiveError];
     
     
     if (archiveData) {
         [self.defaults setObject:archiveData forKey:@"progressTasks"];
         NSLog(@"Updated to-do tasks saved to progress");
     } else {
         NSLog(@"Error archiving updated to-do tasks: %@", archiveError);
     }
     
     
 }


 - (void)addTaskToDone:(Task *)task {
     
     
     NSMutableArray *storedDoneTasks = [self.defaults objectForKey:@"doneTasks"];
     self.doneTasks = [NSMutableArray<Task *> new];

     if (self.doneTasks) {
         NSError *unarchiveError = nil;
         NSSet<Class> *allowedClasses = [NSSet setWithArray:@[NSArray.class, Task.class]];
         NSArray<Task *> *unArchiveDoneTasks = [NSKeyedUnarchiver unarchivedObjectOfClasses:allowedClasses fromData:storedDoneTasks error:&unarchiveError];
         
         if (storedDoneTasks) {
             [self.doneTasks addObjectsFromArray:unArchiveDoneTasks];
         } else {
             NSLog(@"Error unarchiving existing to-do tasks: %@", unarchiveError);
         }
     }
     [self.doneTasks addObject:task];

     NSError *archiveError = nil;
     NSData *archiveData = [NSKeyedArchiver archivedDataWithRootObject:self.doneTasks requiringSecureCoding:YES error:&archiveError];
     
     if (archiveData) {
         [self.defaults setObject:archiveData forKey:@"doneTasks"];
         NSLog(@"Updated to-do tasks saved to UserDefaults");
     } else {
         NSLog(@"Error archiving updated to-do tasks: %@", archiveError);
     }
   
 }


 @end



 */
