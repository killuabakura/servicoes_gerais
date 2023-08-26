import 'package:booking_system_flutter/component/back_widget.dart';
import 'package:booking_system_flutter/component/base_scaffold_body.dart';
import 'package:booking_system_flutter/component/loader_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/user_data_model.dart';
import 'package:booking_system_flutter/screens/auth/auth_user_services.dart';
import 'package:booking_system_flutter/screens/chat/widget/user_item_widget.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../component/empty_error_state_widget.dart';

class ChatListScreen extends StatefulWidget {
  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        language.lblChat,
        textColor: white,
        showBack: Navigator.canPop(context),
        textSize: APP_BAR_TEXT_SIZE,
        elevation: 3.0,
        backWidget: BackWidget(),
        color: context.primaryColor,
      ),
      body: Observer(
        builder: (context) {
          return Body(
            child: appStore.uid.validate().isNotEmpty
                ? FirestorePagination(
                    query: chatServices.fetchChatListQuery(userId: appStore.uid.validate()),
                    physics: AlwaysScrollableScrollPhysics(),
                    isLive: true,
                    shrinkWrap: true,
                    itemBuilder: (context, snap, index) {
                      UserData contact = UserData.fromJson(snap.data() as Map<String, dynamic>);
                      return UserItemWidget(userUid: contact.uid.validate());
                    },
                    initialLoader: LoaderWidget(),
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 10),
                    padding: EdgeInsets.only(left: 0, top: 8, right: 0, bottom: 0),
                    limit: PER_PAGE_CHAT_LIST_COUNT,
                    separatorBuilder: (_, i) => Divider(height: 0, indent: 82, color: context.dividerColor),
                    viewType: ViewType.list,
                    onEmpty: NoDataWidget(
                      title: language.noConversation,
                      subTitle: language.noConversationSubTitle,
                      imageWidget: EmptyStateWidget(),
                    ).paddingSymmetric(horizontal: 16),
                  )
                : NoDataWidget(
                    title: language.noConversation,
                    subTitle: language.noConversationSubTitle,
                    retryText: language.connectWithFirebaseForChat,
                    onRetry: () {
                      setUserInFirebaseIfNotRegistered(context);
                    },
                    imageWidget: EmptyStateWidget(),
                  ).paddingSymmetric(horizontal: 16),
          );
        }
      ),
    );
  }
}
