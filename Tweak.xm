//#import "BulletinBoard/BulletinBoard.h"
#import <UIKit/UIKit2.h>
#import <AVFoundation/AVFoundation.h>
#define isiOS7 (kCFCoreFoundationVersionNumber >= 800.00)

static BOOL isDuplicate = NO;
id previousItem;


@interface VSSpeechSynthesizer : NSObject 
{ 
} 

+ (id)availableLanguageCodes; 
+ (BOOL)isSystemSpeaking; 
- (id)startSpeakingString:(id)string; 
- (id)startSpeakingString:(id)string toURL:(id)url; 
- (id)startSpeakingString:(id)string toURL:(id)url 
withLanguageCode:(id)code; 
- (float)rate;		   // default rate: 1 
- (id)setRate:(float)rate; 
- (float)pitch; 	  // default pitch: 0.5
- (id)setPitch:(float)pitch; 
- (float)volume;       // default volume: 0.8
- (id)setVolume:(float)volume; 
@end

@interface SBBulletinBannerItem
- (id)_appName;
- (id)title;
- (id)message;
- (id)_initWithSeedBulletin:(id)arg1 additionalBulletins:(id)arg2 andObserver:(id)arg3;
@end
@interface SBBulletinBannerView
- (id)initWithItem:(id)arg1;
- (id)bannerItem;
@end

%group iOS6
//%hook SBBulletinBannerView
%hook SBBulletinBannerItem
/*
%new
- (BOOL)ttstIsHeadsetPluggedIn {
    AVAudioSessionRouteDescription* route = [[[AVAudioSession] sharedInstance] currentRoute];
    for (AVAudioSessionPortDescription* desc in [route outputs]) {
	if ([[desc portType] isEqualToString:AVAudioSessionPortHeadphones])
	    return YES;
    }
    return NO;
}
*/
- (id)_initWithSeedBulletin:(id)arg1 additionalBulletins:(id)arg2 andObserver:(id)arg3
//- (id)initWithItem:(id)arg1
{
VSSpeechSynthesizer *speech = 
[[NSClassFromString(@"VSSpeechSynthesizer") alloc] init];
[speech setRate:(float)1.0];

//[speech startSpeakingString:@"Test"];
     //[speech release];
       if(self == %orig)
       {

     if(previousItem == arg1)
	 {
	    isDuplicate = YES;
	 }else{
	    isDuplicate = NO;
	 }
	 previousItem = arg1;

NSString* textToSpeak = [NSString stringWithFormat:@"New %@ notification from: %@, %@.",[self _appName],[self title],[self message]];

//if([self ttstIsHeadsetPluggedIn])
	if(!isDuplicate)[speech startSpeakingString:textToSpeak];

/*[[[[UIAlertView alloc] initWithTitle:[[self bannerItem] title]
			     message:[[self bannerItem]message]
			    delegate:nil
		   cancelButtonTitle:[[self bannerItem]title]
		   otherButtonTitles:nil] autorelease] show];
*/

	//[speech release];
       }

       return %orig; 
}



%end

%hook SBAwayBulletinListItem
- (id)initWithBulletin:(id)arg1 andObserver:(id)arg
{
if(self == %orig)
       {
	   [[[[UIAlertView alloc] initWithTitle:[self title]
			     message:[self message]
			    delegate:nil
		   cancelButtonTitle:[self title]
		   otherButtonTitles:nil] autorelease] show];

       }
       return %orig; 
}

%end
%end

%ctor {
	%init();
	if (isiOS7) {
		//%init(iOS7);
	} else {
		%init(iOS6);
	}
}
