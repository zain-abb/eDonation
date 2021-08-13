import 'package:edonation/src/models/addresses.dart';
import 'package:edonation/src/models/chat.dart';
import 'package:edonation/src/models/feed.dart';
import 'package:edonation/src/models/message.dart';
import 'package:edonation/src/models/posts.dart';
import 'package:edonation/src/models/reviews.dart';
import 'package:edonation/src/models/users.dart';
import 'package:edonation/src/models/donors.dart';

class Arguments {
  Arguments(this.callBack);
  final Map<String, dynamic> callBack;
}

class PostArguments {
  PostArguments(this.user, this.posts, this.initialIndex);
  final Users user;
  final List<Posts> posts;
  final int initialIndex;
}

class PostDetailArguments {
  PostDetailArguments(this.post, this.donors, this.reviews);
  final Posts post;
  final List<Donors> donors;
  final List<Reviews> reviews;
}

class PostDetailDonorArguments {
  PostDetailDonorArguments(this.donors);
  final List<Donors> donors;
}

class PostDetailReviewsArguments {
  PostDetailReviewsArguments(this.reviews);
  final List<Reviews> reviews;
}

class DonationFirstStepArguments {
  DonationFirstStepArguments(this.post);
  final Posts post;
}

class DonationSecondStepArguments {
  DonationSecondStepArguments(this.donation, this.postUserId);
  final Donors donation;
  final String postUserId;
}

class ThankYouArguments {
  ThankYouArguments(this.post);
  final Posts post;
}

class SubmitReviewArguments {
  SubmitReviewArguments(this.post);
  final Posts post;
}

class SinglePostArguments {
  SinglePostArguments(this.userId, this.postId);
  final String userId;
  final String postId;
}

class SingleDonationArguments {
  SingleDonationArguments(this.feed);
  final Feed feed;
}

class SingleReviewArguments {
  SingleReviewArguments(this.feed);
  final Feed feed;
}

class ChatScreenArguments {
  ChatScreenArguments(this.chat, this.newChat);
  final Chat chat;
  final bool newChat;
}

class FullScreenImageArguments {
  FullScreenImageArguments(this.message, this.senderName);
  final Message message;
  final String senderName;
}

class EditAddressArguments {
  EditAddressArguments(this.addresses);
  final Addresses addresses;
}
