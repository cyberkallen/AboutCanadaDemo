//
//  AboutCellTableViewCell.m
//  Test03
//
//  Created by ef on 8/04/2015.
//  Copyright (c) 2015 ef. All rights reserved.
//

#import "AboutCellTableViewCell.h"

@implementation AboutCellTableViewCell


@synthesize titleLabel, descriptionLabel, iconView;

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // title
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 0.0f, 320.0f, 20.0f)];
        titleLabel.font = [UIFont fontWithName:@"Georgia" size:12.0f];
        titleLabel.textColor = [UIColor colorWithRed:0.18f green:0.25f blue:0.45f alpha:1.0];
        [self addSubview:titleLabel];
        [titleLabel release];
        
        // description
        descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 20.0f, 230.0f, 26.0f)];
        descriptionLabel.font = [UIFont fontWithName:@"Arial" size:8.0f];
        descriptionLabel.textColor = [UIColor blackColor];
        descriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
        descriptionLabel.numberOfLines=0;
        [descriptionLabel  setAutoresizingMask:(UIViewAutoresizingFlexibleHeight)];
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:descriptionLabel];
        [descriptionLabel release];
        
        // image
        iconView = [[UIImageView alloc] initWithFrame:CGRectMake(265.0f,5.0f,48.0f,48.f)];
        iconView.tag = 3;
        iconView.autoresizingMask =  UIViewAutoresizingNone;
        [self.contentView addSubview:iconView];
        [iconView release];
        
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    // Make sure the contentView does a layout pass here so that its subviews have their frames set, which we
    // need to use to set the preferredMaxLayoutWidth below.
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
    
    // Set the preferredMaxLayoutWidth of the mutli-line bodyLabel based on the evaluated width of the label's frame,
    // as this will allow the text to wrap correctly, and as a result allow the label to take on the correct height.
    self.textLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.textLabel.frame);
    
}

-(void)dealloc{
    [titleLabel release];
    [descriptionLabel release];
    [iconView release];
    [super dealloc];
}

@end
