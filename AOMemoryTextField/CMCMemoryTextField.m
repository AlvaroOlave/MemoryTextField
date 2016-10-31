//
//  CMCMemoryTextField.m
//  VideoConference
//
//  Created by Alvaro on 25/10/16.
//  Copyright © 2016 CMC. All rights reserved.
//

#import "CMCMemoryTextField.h"

#define AL_DEFAULT_TEXTFIELD_KEY @"AL_DEFAULT_TEXTFIELD_KEY"


@interface CMCMemoryTextField ()

@property (nonatomic, strong) NSString *textFieldKey;
@property (nonatomic, strong) NSMutableArray *previousEntries;

@property (nonatomic) BOOL memoryIsActive;
@property (nonatomic) BOOL memoryIsEnabled;

@end

@implementation CMCMemoryTextField

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.memoryIsActive = YES;
    self.memoryIsEnabled = YES;
    
    [self initializePreviousEntries];
}

- (NSString *)getKey
{
    return self.textFieldKey ? self.textFieldKey : AL_DEFAULT_TEXTFIELD_KEY;
}

- (void)setNameKey:(NSString *)key
{
    self.textFieldKey = key;
    
    [self initializePreviousEntries];
}

- (void)initializePreviousEntries
{
    self.previousEntries = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:[self getKey]]];
    
    if (!self.previousEntries) {
        self.previousEntries = [NSMutableArray array];
    }
}

- (void)saveNewEntry
{
    __block bool exist = NO;
    [self.previousEntries enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isEqualToString:self.text]) {
            exist = YES;
            *stop = true;
        }
    }];
    
    if (!exist) {
        if (self.previousEntries.count > 10) {
            [self.previousEntries removeObjectAtIndex:0];
        }
        [self.previousEntries addObject:self.text];
        [[NSUserDefaults standardUserDefaults] setObject:self.previousEntries forKey:[self getKey]];
    }
}

- (void)filterPreviousOptionsWithTippedText:(NSString *)text
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF BEGINSWITH[c] %@",text];
    NSMutableArray *filteredArray = [self.previousEntries filteredArrayUsingPredicate:predicate].mutableCopy;
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"length" ascending:YES];
    [filteredArray sortUsingDescriptors:@[sortDescriptor]];
    
    if (filteredArray.count > 0) {
        self.memoryIsActive = YES;
        [self selectText:filteredArray.firstObject];
    }else{
        self.memoryIsActive = NO;
    }
}

- (void)selectText:(NSString *)text
{
    if (text.length == self.text.length) {
        self.memoryIsActive = NO;
    }
    
    NSString *newText = [self removeMathchingCharactersOfText:text];
    if (newText) {
        UITextPosition *starts =[self positionFromPosition:self.endOfDocument offset:0];
        
        self.text = [NSString stringWithFormat:@"%@%@",self.text,newText];
        
        UITextPosition *ends =[self positionFromPosition:starts offset:newText.length];
        
        [self setSelectedTextRange:[self textRangeFromPosition:starts toPosition:ends]];
    }
}

- (NSString *)removeMathchingCharactersOfText:(NSString *)text
{
    if (text.length > self.text.length) {
        return [text stringByReplacingCharactersInRange:[text rangeOfString:self.text] withString:@""];
    }
    if (text.length > 0 && text.length == self.text.length) {
        return @"";
    }
    return nil;
}

- (BOOL)shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (range.location + range.length < self.text.length) {//Internal char
        return YES;
    }
    
    if ([string isEqualToString:@""] && self.text.length > 0) {//Deleting
        NSRange newRange = range;
        
        if (self.memoryIsActive) {
            
            self.memoryIsActive =
            self.memoryIsEnabled = NO;
            
            newRange = NSMakeRange(range.location + 1, range.length -1);
        }
        self.text = [self.text stringByReplacingCharactersInRange:[self makeRageWithRange:newRange]
                                                       withString:string];
        
    }else{
        self.memoryIsEnabled = YES;
        self.text = [self.text stringByReplacingCharactersInRange:range withString:string];
    }
    
    if (self.memoryIsEnabled) {
        [self filterPreviousOptionsWithTippedText:self.text];
    }

    return NO;
}

- (NSRange)makeRageWithRange:(NSRange)range
{
    NSLog(@"%@",NSStringFromRange(range));
    NSLog(@"%lu",self.text.length);

    if (range.location == 0 && range.length == self.text.length) {//Delete all
        return range;
    }
    if (range.location == self.text.length - 1 && range.length == 1) {//Delete last char
        if (self.memoryIsActive) {
            return NSMakeRange(range.location - 1 , range.length + 1);
        }
        return NSMakeRange(range.location, range.length);
    }
    return NSMakeRange((range.location == 0) ? range.location : (range.location == self.text.length - 1) ? range.location : range.location - 1,
                       (range.length == 1) ? range.length : (range.location == self.text.length - 1) ? range.length : range.length + 1);
}

@end
