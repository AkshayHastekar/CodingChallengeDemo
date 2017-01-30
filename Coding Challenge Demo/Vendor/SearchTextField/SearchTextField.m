//
//  SearchTextField.m
//  Coding Challenge Demo
//
//  Created by Iftekhar on 30/01/17.
//  Copyright © 2017 Iftekhar. All rights reserved.
//

#import "SearchTextField.h"

@implementation SearchTextField
{
    NSTimer *searchDelayTimer;
}

@synthesize isTyping = _isTyping;
@dynamic delegate;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    [self commonInit];
}

-(void)commonInit
{
    self.stopDelay = 1.0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidEndEditing:) name:UITextFieldTextDidEndEditingNotification object:self];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)textFieldDidChange:(NSNotification*)notification
{
    if (_isTyping == NO)
    {
        _isTyping = YES;

        if ([self.delegate respondsToSelector:@selector(textFieldDidStartTyping:)])
        {
            [self.delegate textFieldDidStartTyping:self];
        }
    }
    
    [searchDelayTimer invalidate];
    searchDelayTimer = [NSTimer scheduledTimerWithTimeInterval:self.stopDelay target:self selector:@selector(delayedTimerSelector:) userInfo:self repeats:NO];
}

-(void)textFieldDidEndEditing:(NSNotification*)notification
{
    if (_isTyping == YES)
    {
        _isTyping = NO;

        if ([self.delegate respondsToSelector:@selector(textFieldDidStopTyping:)])
        {
            [self.delegate textFieldDidStopTyping:self];
        }
        
        if (searchDelayTimer != nil)
        {
            [searchDelayTimer invalidate];
            searchDelayTimer = nil;
        }
    }
}

-(void)delayedTimerSelector:(NSTimer*)timer
{
    if (_isTyping == YES)
    {
        _isTyping = NO;
        if ([self.delegate respondsToSelector:@selector(textFieldDidStopTyping:)])
        {
            [self.delegate textFieldDidStopTyping:self];
        }
        
        if (searchDelayTimer != nil)
        {
            [searchDelayTimer invalidate];
            searchDelayTimer = nil;
        }
    }
}

@end
