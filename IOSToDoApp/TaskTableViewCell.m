//#import "TaskTableViewCell.h"
/*
@implementation TaskTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews {
    // Create and configure the image view
    self.taskImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 80, 80)];
    self.taskImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:self.taskImageView];
    
    // Create and configure the label
    self.taskNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 10, CGRectGetWidth(self.contentView.frame) - 110, 80)];
    self.taskNameLabel.numberOfLines = 0; // Allow multiple lines
    [self.contentView addSubview:self.taskNameLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // Update the frame of the label to fit the cell's content area
    CGFloat labelWidth = CGRectGetWidth(self.contentView.frame) - CGRectGetMaxX(self.taskImageView.frame) - 20;
    self.taskNameLabel.frame = CGRectMake(CGRectGetMaxX(self.taskImageView.frame) + 10, 10, labelWidth, CGRectGetHeight(self.contentView.frame) - 20);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

*/
