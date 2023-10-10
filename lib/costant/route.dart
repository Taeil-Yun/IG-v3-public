import 'package:flutter/material.dart';

import 'package:ig-public_v3/src/auth/email_login.dart';
import 'package:ig-public_v3/src/auth/find_password.dart';
import 'package:ig-public_v3/src/auth/login.dart';
import 'package:ig-public_v3/src/auth/reset_password.dart';
import 'package:ig-public_v3/src/auth/signup.dart';
import 'package:ig-public_v3/view/auction/auction_change_price.dart';
import 'package:ig-public_v3/view/auction/auction_detail.dart';
import 'package:ig-public_v3/view/community/artist_community.dart';
import 'package:ig-public_v3/view/community/other_user_profile.dart';
import 'package:ig-public_v3/view/community/post_detail.dart';
import 'package:ig-public_v3/view/community/sub_reply_list.dart';
import 'package:ig-public_v3/view/notification/notification_list.dart';
import 'package:ig-public_v3/view/profile/bedge/badge_list.dart';
import 'package:ig-public_v3/view/profile/coupon/coupon_box.dart';
import 'package:ig-public_v3/view/profile/gift/gift_box.dart';
import 'package:ig-public_v3/view/profile/history/payment_history.dart';
import 'package:ig-public_v3/view/profile/history/show_history.dart';
import 'package:ig-public_v3/view/profile/history/ticket_history.dart';
import 'package:ig-public_v3/view/profile/payment/money_purchase.dart';
import 'package:ig-public_v3/view/profile/payment/money_refund.dart';
import 'package:ig-public_v3/view/profile/profile/blacklist.dart';
import 'package:ig-public_v3/view/profile/profile/bookmark_post.dart';
import 'package:ig-public_v3/view/profile/profile/edit_profile.dart';
import 'package:ig-public_v3/view/profile/profile/follow.dart';
import 'package:ig-public_v3/view/profile/profile/ticket_cancel.dart';
import 'package:ig-public_v3/view/profile/rank/rank_list.dart';
import 'package:ig-public_v3/view/profile/service/faq.dart';
import 'package:ig-public_v3/view/profile/service/notice_detail.dart';
import 'package:ig-public_v3/view/profile/service/notice_list.dart';
import 'package:ig-public_v3/view/profile/setting/app_setting_list.dart';
import 'package:ig-public_v3/view/profile/setting/notification_setting.dart';
import 'package:ig-public_v3/view/search/search.dart';
import 'package:ig-public_v3/view/seat/auction_seat.dart';
import 'package:ig-public_v3/view/seat/seat_view.dart';
import 'package:ig-public_v3/view/seat/ticketing_seat.dart';
import 'package:ig-public_v3/view/ticketing/ticketing_detail.dart';
import 'package:ig-public_v3/view/community/show_community.dart';
import 'package:ig-public_v3/view/write/community_write.dart';
import 'package:ig-public_v3/view/write/review.dart';

Map<String, WidgetBuilder> routes = {
  // notification
  'notificationList':(context) => const NotificationListScreen(),

  // show history
  'showHistory':(context) => const ShowHistoryScreen(),

  // detail
  'ticketingDetail':(context) => const TicketingDetailScreen(),
  'auctionDetail':(context) => const AuctionDetailScreen(),

  // coupon box
  'couponBox':(context) => const CouponBoxScreen(),

  // gift box
  'giftBox':(context) => const GiftBoxScreen(),

  // service
  'noticeList':(context) => const NoticeListScreen(),
  'noticeDetail':(context) => const NoticeDetailScreen(),
  'faqList':(context) => const FAQListScreen(),

  // setting
  'appSettingList':(context) => const AppSettingListScreen(),
  'notificationSetting':(context) => const NotificationSettingScreen(),

  // history
  'paymentHistory':(context) => const PaymentHistoryScreen(),
  'ticketHistory':(context) => const TicketHistoryScreen(),

  // profile
  'followList':(context) => const FollowListScreen(),
  'bookmarkPost':(context) => const BookmarkPostScreen(),
  'badgeList':(context) => const BadgeListScreen(),
  'rankingList':(context) => const RankingListScreen(),
  'editProfile':(context) => const EditProfileScreen(),
  'ticketCancel':(context) => const TicketCancelScreen(),
  'blacklist':(context) => const BlackListScreen(),

  // payment
  'ig-publicMoneyPurchase':(context) => const ig-publicMoneyPurchaseScreen(),
  'moneyRefund':(context) => const MoneyRefundScreen(),

  // auth
  'login_main':(context) => const ig-publicLoginScreen(),
  'email_login':(context) => const EmailLoginScreen(),
  'find_password':(context) => const FindPasswordScreen(),
  'reset_password':(context) => const ResetPasswordScreen(),
  'signup':(context) => const SignUpScreen(),

  // community
  'showCommunity':(context) => const ShowCommunityScreen(),
  'artistCommunity':(context) => const ArtistCommunityScreen(),
  'postDetail':(context) => const PostDetailScreen(),
  'subReplyList':(context) => const SubReplyListScreen(),
  'otherUserProfile':(context) => const OtherUserProfileScreen(),

  // seat
  'ticketingSeat':(context) => TicketingSeatScreen(showTicketIndex: 0, showContentIndex: 0),
  'auctionSeat':(context) => AuctionSeatScreen(showDetailIndex: 0, showContentIndex: 0),
  'seatView':(context) => SeatViewScreen(showDetailIndex: 0),

  // search
  'searchHome':(context) => const SearchHomeScreen(),

  // login
  'login':(context) => const ig-publicLoginScreen(),

  // write
  'communityWrite':(context) => const CommunityWritingScreen(),
  'reviewWrite':(context) => const ReviewWriteScreen(),

  // auction
  'auctionPriceChange':(context) => const AuctionPriceChangeScreen(),
};