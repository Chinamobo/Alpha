
#import "RFNavigationControllerTransitionDelegate.h"
#import "RFAnimationTransitioning.h"
#import "RFNavigationPopInteractionController.h"

@interface RFNavigationControllerTransitionDelegate ()
@property (readwrite, weak, nonatomic) RFNavigationPopInteractionController *currentPopInteractionController;
@property (readwrite, weak, nonatomic) UIGestureRecognizer *currentPopInteractionGestureRecognizer;
@end

@implementation RFNavigationControllerTransitionDelegate

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {

    // Ask for a TransitionStyle
    BOOL usingToTransitionStyle = YES;
    if (self.preferSourceViewControllerTransitionStyle) {
        usingToTransitionStyle = !usingToTransitionStyle;
    }
    if (operation == UINavigationControllerOperationPop) {
        usingToTransitionStyle = !usingToTransitionStyle;
    }

    NSString *transitionClassName = usingToTransitionStyle? toVC.RFTransitioningStyle : fromVC.RFTransitioningStyle;
    if (!transitionClassName) {
        transitionClassName = navigationController.RFTransitioningStyle;
    }

    // Check class
    Class transitionClass = NSClassFromString(transitionClassName);
    if (!transitionClass
        || ![transitionClass isSubclassOfClass:[RFAnimationTransitioning class]]) {
        return nil;
    }

    RFAnimationTransitioning *animationController = [transitionClass new];
    if (!animationController) {
        return nil;
    }

    // Addition setup
    if ([animationController respondsToSelector:@selector(setReverse:)]) {
        animationController.reverse = (UINavigationControllerOperationPop == operation);
    }

    if (operation == UINavigationControllerOperationPush) {
        // Needs setup pop interaction controller to toVC.
        RFNavigationPopInteractionController *interactionController;
        if (animationController.interactionControllerType) {
            Class controllerClass = NSClassFromString(animationController.interactionControllerType);
            if (controllerClass && [controllerClass isSubclassOfClass:[RFNavigationPopInteractionController class]]) {
                interactionController = [controllerClass new];
            }

            if (interactionController) {
                interactionController.viewController = toVC;
            }
        }
    }
    else {
        // Assign interactionController to animationController.
        // So we can get it in below delegate method.
        animationController.interactionController = fromVC.RFTransitioningInteractionController;
    }

    return animationController;
}

- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController {

    if (![animationController respondsToSelector:@selector(interactionController)]) {
        return nil;
    }

    RFNavigationPopInteractionController *interactionController = [(RFAnimationTransitioning *)animationController interactionController];
    if (![interactionController conformsToProtocol:@protocol(UIViewControllerInteractiveTransitioning)]) {
        return nil;
    }

    if ([interactionController respondsToSelector:@selector(interactionInProgress)]) {
        if (!interactionController.interactionInProgress) {
            return nil;
        }
    }
    return interactionController;
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    self.currentPopInteractionController = (id)viewController.RFTransitioningInteractionController;
    if ([self.delegate respondsToSelector:@selector(navigationController:didShowViewController:animated:)]) {
        [self.delegate navigationController:navigationController didShowViewController:viewController animated:animated];
    }
}

- (void)setCurrentPopInteractionController:(RFNavigationPopInteractionController *)currentPopInteractionController {
    if (_currentPopInteractionController != currentPopInteractionController) {
        if ([_currentPopInteractionController isKindOfClass:[RFNavigationPopInteractionController class]]) {
            [_currentPopInteractionController uninstallGestureRecognizer];
        }

        _currentPopInteractionController = currentPopInteractionController;

        if ([currentPopInteractionController isKindOfClass:[RFNavigationPopInteractionController class]]) {
            [currentPopInteractionController installGestureRecognizer];
            self.currentPopInteractionGestureRecognizer = currentPopInteractionController.gestureRecognizer;
        }
        else {
            self.currentPopInteractionGestureRecognizer = nil;
        }
    }
}

@end
