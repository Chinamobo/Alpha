// Pre TEST

#import "RFKit.h"
#import "AFNetworking.h"

@interface RFShare : NSObject
<UIWebViewDelegate>

+ (instancetype)sharedInstance;

@property (copy, nonatomic) NSString *redirectURI;
@property (copy, nonatomic) NSString *clientID;
@property (readonly, copy, nonatomic) NSString *accessToken;
@property (copy, nonatomic) NSString *clientSecret;


- (void)test;

@property (weak, nonatomic) UIViewController *authorizePresentedViewController;

- (void)presentDefaultAuthorizeWebViewController;

@end