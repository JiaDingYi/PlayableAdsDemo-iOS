//
//  PAPlayableAdsViewController.m
//  PlayableAds_Example
//
//  Created by Michael Tang on 2018/9/20.
//  Copyright © 2018年 on99. All rights reserved.
//

#import "PAPlayableAdsViewController.h"
#import "PADemoUtils.h"
#import <AtmosplayAds/AtmosplayInterstitial.h>
#import <AtmosplayAds/AtmosplayRewardedVideo.h>

@interface PAPlayableAdsViewController () <UITextFieldDelegate, AtmosplayInterstitialDelegate,AtmosplayRewardedVideoDelegate>

@property (weak, nonatomic) IBOutlet UITextField *appIdTextField;
@property (weak, nonatomic) IBOutlet UITextField *adUnitTextField;
@property (weak, nonatomic) IBOutlet UITextView *logTextView;

@property (nonatomic) AtmosplayInterstitial *interstitial;
@property (nonatomic) AtmosplayRewardedVideo *rewardedVideo;
@end

@implementation PAPlayableAdsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = self.isVideo ? @"Video" : @"Interstitial";

    if (!self.isVideo) {
        self.adUnitTextField.text = @"iOSDemoAdUnitInterstitial";
    }

    [self setDelegate];

    [self setVauleToTextField];
}

- (void)setVauleToTextField {

    kAtmosplayAdsType adType = self.isVideo ? kAtmosplayAdsType_video : kAtmosplayAdsType_interstitial;
    PAAdConfigInfo *adConfig = [[PADemoUtils shared] getAdInfo:adType];
    if (!adConfig) {
        [self saveValueToConfig];
        return;
    }

    self.appIdTextField.text = adConfig.appId;
    self.adUnitTextField.text = adConfig.placementId;
}

- (void)saveValueToConfig {
    PAAdConfigInfo *adConfig = [[PAAdConfigInfo alloc] init];
    adConfig.adType = self.isVideo ? kAtmosplayAdsType_video : kAtmosplayAdsType_interstitial;
    ;
    adConfig.appId = self.appIdTextField.text;
    adConfig.placementId = self.adUnitTextField.text;

    [[PADemoUtils shared] saveAdInfo:adConfig];
}

#pragma mark : set delegate
- (void)setDelegate {
    self.appIdTextField.delegate = self;
    self.adUnitTextField.delegate = self;
}

- (void)addLog:(NSString *)newLog {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.logTextView.layoutManager.allowsNonContiguousLayout = NO;
        NSString *oldLog = weakSelf.logTextView.text;
        NSString *text = [NSString stringWithFormat:@"%@\n%@", oldLog, newLog];
        if (oldLog.length == 0) {
            text = [NSString stringWithFormat:@"%@", newLog];
        }
        [weakSelf.logTextView scrollRangeToVisible:NSMakeRange(text.length, 1)];
        weakSelf.logTextView.text = text;
    });
}

#pragma mark : IBAction
- (IBAction)initAdAction:(UIButton *)sender {
    NSString *appId = [[PADemoUtils shared] removeSpaceAndNewline:self.appIdTextField.text];
    NSString *adUnitId = [[PADemoUtils shared] removeSpaceAndNewline:self.adUnitTextField.text];

    if (appId.length == 0) {
        [self addLog:@"app id  is nil"];
        return;
    }
    if (adUnitId.length == 0) {
        [self addLog:@"ad unit id  is nil"];
        return;
    }
    PADemoUtils *util = [PADemoUtils shared];

    [self saveValueToConfig];

    if (self.isVideo) {
        self.rewardedVideo = [[AtmosplayRewardedVideo alloc] initWithAppID:appId AdUnitID:adUnitId];
        self.rewardedVideo.delegate = self;
        self.rewardedVideo.autoLoad = [util autoLoadAd];
        self.rewardedVideo.channelId = [util channelID];
    } else {
        self.interstitial = [[AtmosplayInterstitial alloc] initWithAppID:appId AdUnitID:adUnitId];
        self.interstitial.delegate = self;
        self.interstitial.autoLoad = [util autoLoadAd];
        self.interstitial.channelId = [util channelID];
    }

    NSString *requestText = @"init playable ad ";
    if ([util autoLoadAd]) {
        requestText = @"auto init  playable ad ";
    }
    if ([util channelID].length != 0) {
        requestText = [NSString stringWithFormat:@"%@ and channelID is %@", requestText, [util channelID]];
    }
    [self addLog:requestText];
}

- (IBAction)requestAdAction:(UIButton *)sender {
    if (!self.rewardedVideo || self.interstitial) {
        [self addLog:@"please init playable ad "];
        return;
    }
    [self addLog:@"load playable ad "];
    if (self.isVideo) {
        [self.rewardedVideo loadAd];
    } else {
        [self.interstitial loadAd];
    }
}
- (IBAction)presentAdAction:(UIButton *)sender {
    if (!self.rewardedVideo || self.interstitial) {
        [self addLog:@"playableAd is nil"];
        return;
    }

    if (!self.rewardedVideo.isReady || !self.interstitial.isReady) {
        [self addLog:@"playableAd is not ready"];
        return;
    }
    if (self.isVideo) {
        [self.rewardedVideo showRewardedVideoWithViewController:self];
    } else {
        [self.interstitial showInterstitialWithViewController:self];
    }
}

#pragma mark - Text field delegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - AtmosplayInterstitialDelegate
/// Tells the delegate that succeeded to load ad.
- (void)atmosplayInterstitialDidLoad:(AtmosplayInterstitial *)ads {
    [self addLog:@"atmosplayInterstitialDidLoad"];
}

/// Tells the delegate that failed to load ad.
- (void)atmosplayInterstitial:(AtmosplayInterstitial *)ads didFailToLoadWithError:(NSError *)error {
    [self addLog:@"atmosplayDidFailToLoad"];
}

/// Tells the delegate that user starts playing the ad.
- (void)atmosplayInterstitialDidStartPlaying:(AtmosplayInterstitial *)ads {
    [self addLog:@"atmosplayInterstitialDidStartPlaying"];
}

/// Tells the delegate that the ad is being fully played.
- (void)atmosplayInterstitialDidEndPlaying:(AtmosplayInterstitial *)ads {
    [self addLog:@"atmosplayInterstitialDidEndPlaying"];
}

/// Tells the delegate that the landing page did present on the screen.
- (void)atmosplayInterstitialDidPresentLandingPage:(AtmosplayInterstitial *)ads {
    [self addLog:@"atmosplayInterstitialDidPresentLandingPage"];
}

/// Tells the delegate that the ad did animate off the screen.
- (void)atmosplayInterstitialDidDismissScreen:(AtmosplayInterstitial *)ads {
    [self addLog:@"atmosplayInterstitialDidDismissScreen"];
}

/// Tells the delegate that the ad is clicked
- (void)atmosplayInterstitialDidClick:(AtmosplayInterstitial *)ads {
    [self addLog:@"atmosplayInterstitialDidClick"];
}

#pragma mark - AtmosplayRewardedVideo
/// Tells the delegate that the user should be rewarded.
- (void)atmosplayRewardedVideoDidReceiveReward:(AtmosplayRewardedVideo *)ads {
    [self addLog:@"atmosplayRewardedVideoDidReceiveReward"];
}

/// Tells the delegate that succeeded to load ad.
- (void)atmosplayRewardedVideoDidLoad:(AtmosplayRewardedVideo *)ads {
    [self addLog:@"atmosplayRewardedVideoDidLoad"];
}

/// Tells the delegate that failed to load ad.
- (void)atmosplayRewardedVideo:(AtmosplayRewardedVideo *)ads didFailToLoadWithError:(NSError *)error {
    [self addLog:@"atmosplayRewardedVideoDidFailToLoadWithError"];
}

/// Tells the delegate that user starts playing the ad.
- (void)atmosplayRewardedVideoDidStartPlaying:(AtmosplayRewardedVideo *)ads {
    [self addLog:@"atmosplayRewardedVideoDidStartPlaying"];
}

/// Tells the delegate that the ad is being fully played.
- (void)atmosplayRewardedVideoDidEndPlaying:(AtmosplayRewardedVideo *)ads {
    [self addLog:@"atmosplayRewardedVideoDidEndPlaying"];
}

/// Tells the delegate that the landing page did present on the screen.
- (void)atmosplayRewardedVideoDidPresentLandingPage:(AtmosplayRewardedVideo *)ads {
    [self addLog:@"atmosplayRewardedVideoDidPresentLandingPage"];
}

/// Tells the delegate that the ad did animate off the screen.
- (void)atmosplayRewardedVideoDidDismissScreen:(AtmosplayRewardedVideo *)ads {
    [self addLog:@"atmosplayRewardedVideoDidDismissScreen"];
}

/// Tells the delegate that the ad is clicked
- (void)atmosplayRewardedVideoDidClick:(AtmosplayRewardedVideo *)ads {
    [self addLog:@"atmosplayRewardedVideoDidClick"];
}

@end
