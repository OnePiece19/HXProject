//
//  HXHomeViewController.m
//  HXProject
//
//  重构后首页 - 分组展示、搜索、图标化
//

#import "HXHomeViewController.h"
#import "HXTopicDataManager.h"
#import "HXSectionModel.h"
#import "HXTopicModel.h"

static NSString * const kTopicCellID = @"HXTopicCell";

@interface HXHomeViewController () <UISearchResultsUpdating>

/// 当前展示的数据源 (搜索时为此搜索结果子集)
@property (nonatomic, copy) NSArray<HXSectionModel *> *displaySections;

/// 是否处于搜索模式
@property (nonatomic, assign) BOOL isSearching;

/// 搜索结果（扁平列表）
@property (nonatomic, copy) NSArray<HXTopicModel *> *searchResults;

@end

@implementation HXHomeViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"知识点";
    self.view.backgroundColor = [UIColor whiteColor];

    // 加载全量数据
    self.displaySections = [[HXTopicDataManager sharedManager] allSections];

    [self setupSearchController];
    [self setupTableView];
}

#pragma mark - Setup

- (void)setupSearchController {
    UISearchController *searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    searchController.searchResultsUpdater = self;
    searchController.obscuresBackgroundDuringPresentation = NO;
    searchController.searchBar.placeholder = @"搜索知识点...";
    searchController.searchBar.tintColor = [UIColor colorWithRed:214.0/255 green:60.0/255 blue:43.0/255 alpha:1.0];
    self.navigationItem.searchController = searchController;
    self.definesPresentationContext = YES;
}

- (void)setupTableView {
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kTopicCellID];
    self.tableView.rowHeight = 60;
    self.tableView.sectionHeaderHeight = 60;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 15, 0, 15);
    self.tableView.tableFooterView = [[UIView alloc] init];
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *keyword = searchController.searchBar.text;
    if (keyword.length > 0) {
        self.isSearching = YES;
        self.searchResults = [[HXTopicDataManager sharedManager] searchTopics:keyword];
    } else {
        self.isSearching = NO;
        self.searchResults = nil;
    }
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.isSearching) {
        return 1;
    }
    return self.displaySections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.isSearching) {
        return self.searchResults.count;
    }
    HXSectionModel *sectionModel = self.displaySections[section];
    return sectionModel.collapsed ? 0 : sectionModel.topics.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTopicCellID forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;

    HXTopicModel *topic;
    if (self.isSearching) {
        topic = self.searchResults[indexPath.row];
    } else {
        HXSectionModel *section = self.displaySections[indexPath.section];
        topic = section.topics[indexPath.row];
    }

    // icon + title + subtitle 组合成 attributed string
    NSString *iconText = topic.icon ? [topic.icon stringByAppendingString:@"  "] : @"";
    NSString *fullTitle = [iconText stringByAppendingString:topic.title];

    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:fullTitle];
    [attributedText addAttribute:NSFontAttributeName
                           value:[UIFont boldSystemFontOfSize:16]
                           range:NSMakeRange(0, fullTitle.length)];

    cell.textLabel.attributedText = attributedText;

    // 副标题
    if (topic.subtitle.length > 0) {
        cell.detailTextLabel.text = topic.subtitle;
        cell.detailTextLabel.textColor = [UIColor grayColor];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
    }

    // 收藏标记
    if (topic.isFavorite) {
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"star.fill"]];
        cell.accessoryView.tintColor = [UIColor systemYellowColor];
    } else {
        cell.accessoryView = nil;
    }

    return cell;
}

#pragma mark - UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (self.isSearching) return nil;

    HXSectionModel *sectionModel = self.displaySections[section];

    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor colorWithRed:242.0/255 green:242.0/255 blue:242.0/255 alpha:1.0];

    // icon + title
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = [UIFont boldSystemFontOfSize:16];
    titleLabel.textColor = [UIColor darkTextColor];
    NSString *headerTitle = [NSString stringWithFormat:@"%@  %@", sectionModel.icon, sectionModel.title];
    titleLabel.text = headerTitle;

    // subtitle
    UILabel *subtitleLabel = [[UILabel alloc] init];
    subtitleLabel.font = [UIFont systemFontOfSize:11];
    subtitleLabel.textColor = [UIColor grayColor];
    subtitleLabel.text = sectionModel.subtitle;

    // count badge
    UILabel *countLabel = [[UILabel alloc] init];
    countLabel.font = [UIFont systemFontOfSize:12];
    countLabel.textColor = [UIColor whiteColor];
    countLabel.backgroundColor = [UIColor colorWithRed:214.0/255 green:60.0/255 blue:43.0/255 alpha:1.0];
    countLabel.textAlignment = NSTextAlignmentCenter;
    countLabel.layer.cornerRadius = 11;
    countLabel.layer.masksToBounds = YES;
    countLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)sectionModel.topics.count];

    // toggle icon
    UILabel *toggleIcon = [[UILabel alloc] init];
    toggleIcon.font = [UIFont systemFontOfSize:14];
    toggleIcon.textColor = [UIColor grayColor];
    toggleIcon.text = sectionModel.collapsed ? @"▶" : @"▼";
    toggleIcon.textAlignment = NSTextAlignmentCenter;

    [headerView addSubview:titleLabel];
    [headerView addSubview:subtitleLabel];
    [headerView addSubview:countLabel];
    [headerView addSubview:toggleIcon];

    for (UIView *v in headerView.subviews) {
        v.translatesAutoresizingMaskIntoConstraints = NO;
    }

    [NSLayoutConstraint activateConstraints:@[
        [titleLabel.leadingAnchor constraintEqualToAnchor:headerView.leadingAnchor constant:16],
        [titleLabel.topAnchor constraintEqualToAnchor:headerView.topAnchor constant:8],

        [subtitleLabel.leadingAnchor constraintEqualToAnchor:titleLabel.leadingAnchor],
        [subtitleLabel.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:2],

        [countLabel.centerYAnchor constraintEqualToAnchor:headerView.centerYAnchor],
        [countLabel.trailingAnchor constraintEqualToAnchor:toggleIcon.leadingAnchor constant:-8],
        [countLabel.widthAnchor constraintGreaterThanOrEqualToConstant:26],
        [countLabel.heightAnchor constraintEqualToConstant:22],

        [toggleIcon.centerYAnchor constraintEqualToAnchor:headerView.centerYAnchor],
        [toggleIcon.trailingAnchor constraintEqualToAnchor:headerView.trailingAnchor constant:-16],
        [toggleIcon.widthAnchor constraintEqualToConstant:20],
        [toggleIcon.heightAnchor constraintEqualToConstant:20],
    ]];

    // 点击手势：折叠/展开
    headerView.tag = section;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapSectionHeader:)];
    [headerView addGestureRecognizer:tap];

    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.isSearching) return 0;
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    HXTopicModel *topic;
    if (self.isSearching) {
        topic = self.searchResults[indexPath.row];
    } else {
        HXSectionModel *section = self.displaySections[indexPath.section];
        topic = section.topics[indexPath.row];
    }

    [self navigateToTopic:topic];
}

#pragma mark - UISwipeActionsConfiguration (Trailing swipe to toggle favorite)

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    HXTopicModel *topic;
    if (self.isSearching) {
        if (indexPath.row >= self.searchResults.count) return nil;
        topic = self.searchResults[indexPath.row];
    } else {
        HXSectionModel *section = self.displaySections[indexPath.section];
        if (indexPath.row >= section.topics.count) return nil;
        topic = section.topics[indexPath.row];
    }

    NSString *actionTitle = topic.isFavorite ? @"取消收藏" : @"收藏";
    UIContextualAction *action = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal
                                                                         title:actionTitle
                                                                       handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        [[HXTopicDataManager sharedManager] toggleFavorite:topic.topicId];
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        completionHandler(YES);
    }];
    action.backgroundColor = topic.isFavorite ? [UIColor systemGrayColor] : [UIColor systemOrangeColor];

    return [UISwipeActionsConfiguration configurationWithActions:@[action]];
}

#pragma mark - Actions

- (void)didTapSectionHeader:(UITapGestureRecognizer *)tap {
    NSInteger section = tap.view.tag;
    if (section < 0 || section >= self.displaySections.count) return;

    HXSectionModel *sectionModel = self.displaySections[section];
    sectionModel.collapsed = !sectionModel.collapsed;

    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section]
                  withRowAnimation:UITableViewRowAnimationFade];
}

- (void)navigateToTopic:(HXTopicModel *)topic {
    if (!topic.vcClass || topic.vcClass.length == 0) {
        NSLog(@"⚠️ No vcClass configured for topic: %@", topic.topicId);
        return;
    }

    Class cls = NSClassFromString(topic.vcClass);
    if (!cls) {
        NSLog(@"⚠️ Class not found: %@", topic.vcClass);
        return;
    }

    UIViewController *vc = [[cls alloc] init];
    if (![vc isKindOfClass:[UIViewController class]]) {
        NSLog(@"⚠️ %@ is not a UIViewController subclass", topic.vcClass);
        return;
    }

    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

@end