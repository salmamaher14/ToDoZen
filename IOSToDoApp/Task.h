//
//  Task.h
//  IOSToDoApp
//
//  Created by Salma on 17/04/2024.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Task : NSObject<NSCoding,NSSecureCoding>

@property (nonatomic, strong) NSString *taskName;
@property (nonatomic, strong) NSString *priority;
@property (nonatomic, strong) NSString *taskDescription;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSDate *taskDate;


- (void) encodeWithCoder:(NSCoder *)coder;

- (instancetype)initWithName:(NSString *)name priority:(NSString *)priority taskDescription:(NSString *)taskDescription state:(NSString *)state date:(NSDate *)date;
@end

NS_ASSUME_NONNULL_END


