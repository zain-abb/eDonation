import 'package:edonation/src/models/callback_arguments.dart';
import 'package:edonation/src/views/ui/auth/forgot_password_screen.dart';
import 'package:edonation/src/views/ui/auth/reset_password_screen.dart';
import 'package:edonation/src/views/ui/auth/verification_completed_screen.dart';
import 'package:edonation/src/views/ui/auth/verification_screen.dart';
import 'package:edonation/src/views/ui/donations/donation_first_step.dart';
import 'package:edonation/src/views/ui/donations/donation_second_step.dart';
import 'package:edonation/src/views/ui/donations/submit_review.dart';
import 'package:edonation/src/views/ui/donations/thank_you.dart';
import 'package:edonation/src/views/ui/feed/activity_feed.dart';
import 'package:edonation/src/views/ui/home/home_screen.dart';
import 'package:edonation/src/views/ui/messages/chat_list_screen.dart';
import 'package:edonation/src/views/ui/messages/chat_screen.dart';
import 'package:edonation/src/views/ui/posts/add_post_splash_screen.dart';
import 'package:edonation/src/views/ui/posts/campaign_created_screen.dart';
import 'package:edonation/src/views/ui/posts/campaign_detail_screen.dart';
import 'package:edonation/src/views/ui/posts/campaign_duration_screen.dart';
import 'package:edonation/src/views/ui/posts/campaign_image_screen.dart';
import 'package:edonation/src/views/ui/posts/campaign_issues_screen.dart';
import 'package:edonation/src/views/ui/posts/campaign_location_screen.dart';
import 'package:edonation/src/views/ui/posts/campaign_requirements_screen.dart';
import 'package:edonation/src/views/ui/posts/campaign_target_screen.dart';
import 'package:edonation/src/views/ui/posts/campaign_title_screen.dart';
import 'package:edonation/src/views/ui/profile/user_edit_profile.dart';
import 'package:edonation/src/views/ui/profile/user_post_detail.dart';
import 'package:edonation/src/views/ui/profile/user_post_donors.dart';
import 'package:edonation/src/views/ui/profile/user_post_list.dart';
import 'package:edonation/src/views/ui/profile/user_post_reviews.dart';
import 'package:edonation/src/views/ui/profile/user_profile.dart';
import 'package:edonation/src/views/ui/search/search_screen.dart';
import 'package:edonation/src/views/ui/settings/addresses/add_new_address.dart';
import 'package:edonation/src/views/ui/settings/addresses/address_list.dart';
import 'package:edonation/src/views/ui/settings/addresses/edit_address.dart';
import 'package:edonation/src/views/ui/settings/contact_us.dart';
import 'package:edonation/src/views/ui/settings/donations_record.dart';
import 'package:edonation/src/views/ui/settings/help.dart';
import 'package:edonation/src/views/ui/settings/preferences_screen.dart';
import 'package:edonation/src/views/ui/settings/saved_posts.dart';
import 'package:edonation/src/views/ui/settings/settings/change_password.dart';
import 'package:edonation/src/views/ui/settings/settings/settings.dart';
import 'package:edonation/src/views/ui/single/single_donation.dart';
import 'package:edonation/src/views/ui/single/single_post.dart';
import 'package:edonation/src/views/ui/single/single_review.dart';
import 'package:edonation/src/views/utils/widgets/full_screen_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'src/helpers/custom_route_transition.dart';
import 'src/views/ui/home/pager.dart';
import 'src/views/ui/splash/splash_screen.dart';
import 'src/views/ui/auth/profile.dart';
import 'src/views/ui/auth/auth_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarBrightness: Brightness.dark));

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Future<FirebaseApp> _initialization = Firebase.initializeApp();
    return FutureBuilder(
      future: _initialization,
      builder: (context, appSnapshot) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'eDonation',
          themeMode: ThemeMode.light,
          theme: ThemeData(
            pageTransitionsTheme: PageTransitionsTheme(
              builders: {
                TargetPlatform.android: CustomPageTransitionBuilder(),
                TargetPlatform.iOS: CustomPageTransitionBuilder(),
              },
            ),
          ),
          routes: {
            // Auth Screens
            AuthScreen.routeName: (ctx) => AuthScreen(),
            ProfileScreen.routeName: (ctx) => ProfileScreen(),
            ForgotPasswordScreen.routeName: (ctx) => ForgotPasswordScreen(),
            ResetPasswordScreen.routeName: (ctx) => ResetPasswordScreen(),
            VerificationScreen.routeName: (ctx) => VerificationScreen(),
            VerificationCompletedScreen.routeName: (ctx) =>
                VerificationCompletedScreen(),

            // PageView Screens
            Pager.routeName: (ctx) => Pager(),
            HomeScreen.routeName: (ctx) => HomeScreen(),
            AddPostSplashScreen.routeName: (ctx) => AddPostSplashScreen(),
            SearchScreen.routeName: (ctx) => SearchScreen(),
            ChatListScreen.routeName: (ctx) => ChatListScreen(),
            PreferencesScreen.routeName: (ctx) => PreferencesScreen(),
            // Add Post Screens
            CampaignIssuesScreen.routeName: (ctx) => CampaignIssuesScreen(),
            CampaignTitleScreen.routeName: (ctx) => CampaignTitleScreen(),
            CampaignRequirementScreen.routeName: (ctx) =>
                CampaignRequirementScreen(),
            CampaignDetailScreen.routeName: (ctx) => CampaignDetailScreen(),
            CampaignImageScreen.routeName: (ctx) => CampaignImageScreen(),
            CampaignLocationScreen.routeName: (ctx) => CampaignLocationScreen(),
            CampaignTargetScreen.routeName: (ctx) => CampaignTargetScreen(),
            CampaignDurationScreen.routeName: (ctx) => CampaignDurationScreen(),
            CampaignCreatedScreen.routeName: (ctx) => CampaignCreatedScreen(),

            EditUserProfile.routeName: (ctx) => EditUserProfile(),
            ActivityFeed.routeName: (ctx) => ActivityFeed(),

            // Preferences
            DonationsRecord.routeName: (ctx) => DonationsRecord(),
            SavedPosts.routeName: (ctx) => SavedPosts(),
            AddressList.routeName: (ctx) => AddressList(),
            AddNewAddress.routeName: (ctx) => AddNewAddress(),
            Settings.routeName: (ctx) => Settings(),
            ChangePassword.routeName: (ctx) => ChangePassword(),
            ContactUs.routeName: (ctx) => ContactUs(),
            Help.routeName: (ctx) => Help(),
          },
          onGenerateRoute: (RouteSettings settings) {
            // User Profile
            late PostArguments postArguments;
            late PostDetailArguments postDetailArguments;
            late PostDetailDonorArguments postDetailDonorArguments;
            late PostDetailReviewsArguments postDetailReviewsArguments;
            if (settings.name == UserPostList.routeName) {
              final args = settings.arguments;
              postArguments = args as PostArguments;
            }
            if (settings.name == UserPostDetail.routeName) {
              final args = settings.arguments;
              postDetailArguments = args as PostDetailArguments;
            }
            if (settings.name == UserPostDonors.routeName) {
              final args = settings.arguments;
              postDetailDonorArguments = args as PostDetailDonorArguments;
            }
            if (settings.name == UserPostReviews.routeName) {
              final args = settings.arguments;
              postDetailReviewsArguments = args as PostDetailReviewsArguments;
            }

            // Donation Steps
            late DonationFirstStepArguments donationFirstStepArguments;
            late DonationSecondStepArguments donationSecondStepArguments;
            late ThankYouArguments thankYouArguments;
            late SubmitReviewArguments submitReviewArguments;
            if (settings.name == DonationFirstStep.routeName) {
              final args = settings.arguments;
              donationFirstStepArguments = args as DonationFirstStepArguments;
            }
            if (settings.name == DonationSecondStep.routeName) {
              final args = settings.arguments;
              donationSecondStepArguments = args as DonationSecondStepArguments;
            }
            if (settings.name == ThankYou.routeName) {
              final args = settings.arguments;
              thankYouArguments = args as ThankYouArguments;
            }
            if (settings.name == SubmitReview.routeName) {
              final args = settings.arguments;
              submitReviewArguments = args as SubmitReviewArguments;
            }

            // Single
            late SinglePostArguments singlePostArguments;
            late SingleDonationArguments singleDonationArguments;
            late SingleReviewArguments singleReviewArguments;
            if (settings.name == SinglePost.routeName) {
              final args = settings.arguments;
              singlePostArguments = args as SinglePostArguments;
            }
            if (settings.name == SingleDonation.routeName) {
              final args = settings.arguments;
              singleDonationArguments = args as SingleDonationArguments;
            }
            if (settings.name == SingleReview.routeName) {
              final args = settings.arguments;
              singleReviewArguments = args as SingleReviewArguments;
            }

            // Chat
            late ChatScreenArguments chatScreenArguments;
            if (settings.name == ChatScreen.routeName) {
              final args = settings.arguments;
              chatScreenArguments = args as ChatScreenArguments;
            }

            // Full Screen Image
            late FullScreenImageArguments fullScreenImageArguments;
            if (settings.name == FullScreenImage.routeName) {
              final args = settings.arguments;
              fullScreenImageArguments = args as FullScreenImageArguments;
            }

            // Addresses
            late EditAddressArguments editAddressArguments;
            if (settings.name == EditAddress.routeName) {
              final args = settings.arguments;
              editAddressArguments = args as EditAddressArguments;
            }
            var routes = <String, WidgetBuilder>{
              // User Profile
              UserProfile.routeName: (ctx) =>
                  UserProfile(settings.arguments as String),
              UserPostList.routeName: (ctx) => UserPostList(postArguments.user,
                  postArguments.posts, postArguments.initialIndex),
              UserPostDetail.routeName: (ctx) => UserPostDetail(
                  postDetailArguments.post,
                  postDetailArguments.donors,
                  postDetailArguments.reviews),
              UserPostDonors.routeName: (ctx) =>
                  UserPostDonors(postDetailDonorArguments.donors),
              UserPostReviews.routeName: (ctx) =>
                  UserPostReviews(postDetailReviewsArguments.reviews),

              // Donation Steps
              DonationFirstStep.routeName: (ctx) =>
                  DonationFirstStep(donationFirstStepArguments.post),
              DonationSecondStep.routeName: (ctx) => DonationSecondStep(
                  donationSecondStepArguments.donation,
                  donationSecondStepArguments.postUserId),
              ThankYou.routeName: (ctx) => ThankYou(thankYouArguments.post),
              SubmitReview.routeName: (ctx) =>
                  SubmitReview(submitReviewArguments.post),

              // Single
              SinglePost.routeName: (ctx) => SinglePost(
                  singlePostArguments.userId, singlePostArguments.postId),
              SingleDonation.routeName: (ctx) =>
                  SingleDonation(singleDonationArguments.feed),
              SingleReview.routeName: (ctx) =>
                  SingleReview(singleReviewArguments.feed),

              // Chat
              ChatScreen.routeName: (ctx) => ChatScreen(
                  chatScreenArguments.chat, chatScreenArguments.newChat),

              // Full Screen Image
              FullScreenImage.routeName: (ctx) => FullScreenImage(
                  fullScreenImageArguments.message,
                  fullScreenImageArguments.senderName),

              // Addresses
              EditAddress.routeName: (ctx) =>
                  EditAddress(editAddressArguments.addresses),
            };
            WidgetBuilder builder = routes[settings.name]!;
            return MaterialPageRoute(builder: (ctx) => builder(ctx));
          },
          home: appSnapshot.connectionState != ConnectionState.done
              ? SplashScreen()
              : StreamBuilder(
                  stream: FirebaseAuth.instance.authStateChanges(),
                  builder: (ctx, userSnapshot) {
                    if (userSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return SplashScreen();
                    }
                    if (userSnapshot.hasData) {
                      return Pager();
                    }
                    return AuthScreen();
                  },
                ),
          // home: DonationsRecord(),
        );
      },
    );
  }
}
