
#import "RFFetchedResultsTableView.h"

@interface RFFetchedResultsTableView ()
@property (RF_STRONG, readwrite, nonatomic) NSFetchedResultsController *fetchController;

@end

@implementation RFFetchedResultsTableView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self setupFetchController];
}

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    if (self = [super initWithFrame:frame style:style]) {
        [self setupFetchController];
    }
    return self;
}

- (void)setupFetchController {
    if (self.managedObjectContext && self.request) {
        self.fetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:self.request managedObjectContext:self.managedObjectContext sectionNameKeyPath:self.fetchSectionNameKeyPath cacheName:self.fetchCacheName];
        self.fetchController.delegate = self;
        [self performFetch];
    }
    
    [self addObserver:self forKeyPath:@"request" options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:@"request.predicate" options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:@"request.sortDescriptors" options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:@"managedObjectContext" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)performFetch {
    if (self.fetchController) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *e = nil;
            [self.fetchController performFetch:&e];
            if (e) douto(e);
            
            [self reloadData];
        });
    }
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"request"];
    [self removeObserver:self forKeyPath:@"request.predicate"];
    [self removeObserver:self forKeyPath:@"request.sortDescriptors"];
    [self removeObserver:self forKeyPath:@"managedObjectContext"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"request"]) {
        if (self.managedObjectContext) {
            self.fetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:self.request managedObjectContext:self.managedObjectContext sectionNameKeyPath:self.fetchSectionNameKeyPath cacheName:self.fetchCacheName];
            [self performFetch];
        }
        return;
    }
    
    if ([keyPath isEqualToString:@"request.predicate"] ||
        [keyPath isEqualToString:@"request.sortDescriptors"]) {
        [self performFetch];
        return;
    }
    
    if ([keyPath isEqualToString:@"managedObjectContext"]) {
        if (self.request) {
            self.fetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:self.request managedObjectContext:self.managedObjectContext sectionNameKeyPath:self.fetchSectionNameKeyPath cacheName:self.fetchCacheName];
            [self performFetch];
        }
        return;
    }
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (self.cellConfigureBlock) {
        self.cellConfigureBlock(cell, indexPath);
    }
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger count = [[self.fetchController sections] count];
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

#pragma mark - NSFetchedResultsControllerDelegate
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	[self beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
	UITableView *table = self;
	switch(type) {
			
		case NSFetchedResultsChangeInsert:
			[table insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
			break;
			
		case NSFetchedResultsChangeDelete:
			[table deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
			break;
			
		case NSFetchedResultsChangeUpdate:
            if (self.cellConfigureBlock) {
                self.cellConfigureBlock([table cellForRowAtIndexPath:indexPath], indexPath);
            }
			break;
			
		case NSFetchedResultsChangeMove:
            [table moveRowAtIndexPath:[NSArray arrayWithObject:indexPath] toIndexPath:[NSArray arrayWithObject:newIndexPath]];
			break;
	}
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
	UITableView *table = self;
	switch(type) {
			
		case NSFetchedResultsChangeInsert:
			[table insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[table deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
            
        case NSFetchedResultsChangeUpdate:
            break;
            
        case NSFetchedResultsChangeMove:
            break;
	}
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	[self endUpdates];
}


@end
