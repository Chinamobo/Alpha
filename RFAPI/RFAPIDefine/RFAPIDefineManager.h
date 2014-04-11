
#import "RFAPIDefine.h"
#import "RFInitializing.h"

@class RFAPI;

@interface RFAPIDefineManager : NSObject <RFInitializing>
@property (weak, nonatomic) RFAPI *master;

@property (strong, nonatomic) RFAPIDefine *defaultDefine;

- (void)mergeWithRules:(NSMutableDictionary *)rules;
- (RFAPIDefine *)defineForName:(NSString *)defineName;

#pragma mark - RFAPI Support
- (id)requestSerializerForDefine:(RFAPIDefine *)define;
- (id)responseSerializerForDefine:(RFAPIDefine *)define;

@end

@interface RFAPIDefine (RFConfigFile)
- (id)initWithRule:(NSDictionary *)rule;

@end
