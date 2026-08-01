class StoryModel {
  final String id;
  final String userId;
  final String userName;
  final String userImage;
  final String mediaUrl;
  final String mediaType;
  final DateTime timestamp;
  bool viewed;

  StoryModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userImage,
    required this.mediaUrl,
    required this.mediaType,
    required this.timestamp,
    this.viewed = false,
  });

  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inDays > 0) return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
    if (diff.inHours > 0) return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes} minute${diff.inMinutes > 1 ? 's' : ''} ago';
    return 'Just now';
  }
}

class UserStories {
  final String userId;
  final String userName;
  final String userImage;
  final List<StoryModel> stories;

  UserStories({
    required this.userId,
    required this.userName,
    required this.userImage,
    required this.stories,
  });

  bool get hasUnviewedStories => stories.any((s) => !s.viewed);
  StoryModel get latestStory => stories.last;
}