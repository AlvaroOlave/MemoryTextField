//
//  AOMemoryTextField.m
//  VideoConference
//
//  Created by Alvaro on 25/10/16.
//  Copyright © 2016 AO. All rights reserved.
//

#import "AOMemoryTextField.h"

#define AL_DEFAULT_TEXTFIELD_KEY        @"AL_DEFAULT_TEXTFIELD_KEY"
#define AL_DEFAULT_MEMORY_CAPACITY      10

@interface AOMemoryTextField ()

@property (nonatomic, strong) NSString *textFieldKey;
@property (nonatomic, strong) NSMutableArray *previousEntries;

@property (nonatomic) NSUInteger capacity;

@property (nonatomic) BOOL isReminding;
@property (nonatomic) BOOL memoryIsEnabled;

@property (nonatomic) kAOFilterResults resultPolicy;

@property (nonatomic, strong) NSPredicate *evalPredicate;

@end

@implementation AOMemoryTextField

@synthesize dataManagerDelegate = _dataManagerDelegate;


- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.isReminding =
    self.memoryIsEnabled = YES;
    self.resultPolicy = kAOFilterResultsNoPolicySelected;
    
    self.capacity = AL_DEFAULT_MEMORY_CAPACITY;
    
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

- (void)setFilterResultsPolicy:(kAOFilterResults)resultsPolicy
{
    self.resultPolicy = resultsPolicy;
}

- (void)setEvaluationPredicate:(NSPredicate *)predicate
{
    self.evalPredicate = predicate;
}

- (void)setMemoryCapacity:(NSUInteger)capacity
{
    self.capacity = MAX(capacity, 1);
}

- (void)initializePreviousEntries
{
    if (self.dataManagerDelegate) {
        [self.dataManagerDelegate getMemorizedWordsWithKey:[self getKey] withCompletion:^(NSArray<NSString *> *entries) {
            self.previousEntries = [NSMutableArray arrayWithArray:entries];
        }];
    }else{
        
        self.previousEntries = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:[self getKey]]];
        
    }
    
    if (!self.previousEntries) {
        self.previousEntries = [NSMutableArray array];
    }
}

- (void)saveNewEntry
{
    if ([self evaluateString]) {
        if (self.dataManagerDelegate) {
            [self.dataManagerDelegate saveNewWord:self.text];
        }else{
            
            NSArray *matchedArray = [self.previousEntries filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF MATCHES[c] %@",self.text]];
            
            if (matchedArray.count == 0) {
                if (self.previousEntries.count > self.capacity) {
                    [self.previousEntries removeObjectAtIndex:0];
                }
                [self.previousEntries addObject:self.text];   
                [[NSUserDefaults standardUserDefaults] setObject:self.previousEntries forKey:[self getKey]];
            }
        }
    }
}

- (BOOL)evaluateString
{
    return (self.evalPredicate) ? [self.evalPredicate evaluateWithObject:self.text] : YES;
}

- (void)clearMemory
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[self getKey]];
}

- (void)filterPreviousOptionsWithTippedText:(NSString *)text
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF BEGINSWITH[c] %@",text];
    NSMutableArray *filteredArray = [self.previousEntries filteredArrayUsingPredicate:predicate].mutableCopy;
    
    NSSortDescriptor *sortDescriptor = [self shortDescriptor];
    
    [filteredArray sortUsingDescriptors:@[sortDescriptor]];
    
    if (filteredArray.count > 0) {
        self.isReminding = YES;
        [self selectText:filteredArray.firstObject];
    }else{
        self.isReminding = NO;
    }
}

- (void)selectText:(NSString *)text
{
    if (text.length == self.text.length) {
        self.isReminding = NO;
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
        
        if (self.isReminding) {
            
            self.isReminding =
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

- (NSSortDescriptor *)shortDescriptor
{
    return (self.resultPolicy == kAOFilterResultsLastInFirstOut) ?
        [NSSortDescriptor sortDescriptorWithKey: @"self" ascending: NO] :
    (self.resultPolicy == kAOFilterResultsFirstInFirstOut) ?
        [NSSortDescriptor sortDescriptorWithKey: @"self" ascending: YES] :
        [[NSSortDescriptor alloc] initWithKey:@"length" ascending:[self shortResultsPolicySelected]];
}

- (BOOL)shortResultsPolicySelected
{
    return (self.resultPolicy == kAOFilterResultsLongestFirst) ? NO : YES;
}

- (NSRange)makeRageWithRange:(NSRange)range
{
    if (range.location == 0 && range.length == self.text.length) {//Delete all
        return range;
    }
    if (range.location == self.text.length - 1 && range.length == 1) {//Delete last char
        if (self.isReminding) {
            return NSMakeRange(range.location - 1 , range.length + 1);
        }
        return NSMakeRange(range.location, range.length);
    }
    return NSMakeRange((range.location == 0) ? range.location : (range.location == self.text.length - 1) ? range.location : range.location - 1,
                       (range.length == 1) ? range.length : (range.location == self.text.length - 1) ? range.length : range.length + 1);
}

@end
