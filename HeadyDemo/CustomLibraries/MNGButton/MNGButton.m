//
//  MNGButton.m
//  UTGo
//
//  Created by Shridhar Sawant on 13/10/17.
//  Copyright © 2017 Plexitech. All rights reserved.
//

#import "MNGButton.h"

@implementation MNGButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    //increase touch area for control in all directions by 20
    CGFloat margin = 10.0;
    CGRect area = CGRectInset(self.bounds, -margin, -margin);
    return CGRectContainsPoint(area, point);
}

@end
