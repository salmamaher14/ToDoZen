//
//  Task.m
//  IOSToDoApp
//
//  Created by Salma on 17/04/2024.
//

#import "Task.h"

@implementation Task
+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.taskName forKey:@"name"];
    [encoder encodeObject:self.taskDescription forKey:@"taskDescription"];
    [encoder encodeObject:self.state forKey:@"state"];
    [encoder encodeObject:self.taskDate forKey:@"date"];
    [encoder encodeObject:self.priority forKey:@"pariority"];
}


- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _taskName = [coder decodeObjectOfClass:[NSString class] forKey:@"name"];
        _taskDescription = [coder decodeObjectOfClass:[NSString class] forKey:@"taskDescription"];
        _priority = [coder decodeObjectOfClass:[NSString class] forKey:@"pariority"];
        _state = [coder decodeObjectOfClass:[NSString class] forKey:@"state"];
        _taskDate = [coder decodeObjectOfClass:[NSDate class] forKey:@"date"];
    }
    return self;
}


- (instancetype)initWithName:(NSString *)name priority:(NSString *)priority taskDescription:(NSString *)taskDescription state:(NSString *)state date:(NSDate *)date {
    self = [super init];
    if (self) {
        _taskName = name;
        _state =state ;
        _taskDescription=taskDescription;
        _priority=priority;
        _taskDate=date;
    }
    return self;
}
@end




