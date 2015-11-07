#import <UIKit/UIKit.h>

@interface _UIActionSlider// : UIControl
@property (nonatomic, assign) id delegate; //<_UIActionSliderDelegate> *
@property (getter=_knobView, nonatomic, readonly) UIView *knobView;
@property (nonatomic, copy) NSString *trackText;
@property (nonatomic, retain) UIColor *knobColor;
@property (nonatomic, retain) UIImage *knobImage;
@property (nonatomic, assign) int tag;

- (void)setTintColor:(UIColor *)color;
-(CGRect)frame;
- (id)initWithFrame:(CGRect)arg1;
- (double)trackWidthProportion;
@end

@interface SBPowerDownView {
    _UIActionSlider *_actionSlider;
}
- (id)valueForKey:(NSString *)key;
- (void)addSubview:(id)view;

- (void)_resetAutoDismissTimer;
- (void)_cancelAutoDismissTimer;
@end

@interface SpringBoard
- (void)relaunchSpringBoard;
- (void)reboot;
@end

%hook SBPowerDownView

- (void)actionSliderDidCancelSlide:(_UIActionSlider *)arg1 {
    if (arg1.tag == 0) {
        %orig;
    }else{
        [self _resetAutoDismissTimer];
    }
}
- (void)actionSliderDidCompleteSlide:(_UIActionSlider *)arg1 {
    if (arg1.tag == 1) {
        if ([arg1 trackWidthProportion] == 1.0f) {
            [(SpringBoard *)[UIApplication sharedApplication] reboot];
        }
    }else if (arg1.tag == 2) {
        if ([arg1 trackWidthProportion] == 1.0f) {
            [(SpringBoard *)[UIApplication sharedApplication] relaunchSpringBoard];
        }
    }else { //(arg1.tag == 0)
        %orig;
    }
}
/*
- (void)actionSlider:(_UIActionSlider *)arg1 didUpdateSlideWithValue:(double)arg2 {
    HBLogWarn(@"%@ %f", arg1, arg2);
    %orig;
}*/
- (void)actionSliderDidBeginSlide:(_UIActionSlider *)arg1 {
    if (arg1.tag == 0) {
        %orig;
    }else{
        [self _cancelAutoDismissTimer];
    }
}


- (void)animateIn {
//- (id)initWithFrame:(CGRect)arg1 {
    NSDictionary* prefDic = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/kr.iolate.sbpoweroption.plist"];
    NSString* rebootString = [prefDic objectForKey:@"StringReboot"];
    if (rebootString == nil || [rebootString isEqualToString:@""]) rebootString = @"slide to reboot";
    NSString* respringString = [prefDic objectForKey:@"StringRespring"];
    if (respringString == nil || [respringString isEqualToString:@""]) respringString = @"slide to respring";
    
    _UIActionSlider* ac = [self valueForKey:@"_actionSlider"];
    CGRect sliderFrame = ac.frame;
    double lastY = sliderFrame.origin.y;
    double sliderHeight = sliderFrame.size.height;
    double margin = sliderFrame.origin.y + sliderHeight;
    
#define NEW_SLIDER(var, tag_, color, image, text) \
    _UIActionSlider* var = [[NSClassFromString(@"_UIActionSlider") alloc] \
        initWithFrame:CGRectMake(sliderFrame.origin.x, lastY + margin, sliderFrame.size.width, sliderFrame.size.height)]; \
    lastY += margin; \
    var.tag = tag_; \
    [var setTintColor:color]; \
    [var setKnobImage:image]; \
    [var setTrackText:text]; \
    [var setDelegate:self]; \
    [self addSubview:var];
    
    NEW_SLIDER(rebootSlider, 1, [UIColor orangeColor], [ac knobImage], rebootString); //slide to reboot
    
    NSString* imagePath = @"/Library/PreferenceLoader/Preferences/SBPowerOption@3x.png";
    UIImage *image = [[UIImage imageWithContentsOfFile:imagePath] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    NEW_SLIDER(respringSlider, 2, [UIColor greenColor], image, respringString);
    
    %orig;
}

%end

