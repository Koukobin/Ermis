// Deprecated: unused notification service leveraging AwesomeNotifications, retained for reference.

/*
///  *********************************************
///     NOTIFICATION CONTROLLER
///  *********************************************
///
class NotificationService {
  static ReceivedAction? initialAction;

  ///  *********************************************
  ///     INITIALIZATIONS
  ///  *********************************************
  ///
  static Future<void> init() async {
    await AwesomeNotifications().initialize(
      null, //'resource://drawable/res_app_icon',//
      [
        NotificationChannel(
          channelKey: 'basic_channel',
          channelName: 'Basic channel',
          channelDescription: 'Notification tests as alerts',
          playSound: true,
          onlyAlertOnce: true,
          groupAlertBehavior: GroupAlertBehavior.Children,
          importance: NotificationImportance.High,
          defaultPrivacy: NotificationPrivacy.Private,
          defaultColor: AppConstants.darkAppColors.primaryColor,
          ledColor: AppConstants.darkAppColors.primaryColor,
        ),
        NotificationChannel(
          channelKey: 'voice_call_channel',
          channelName: 'Voice Call Notifications',
          channelDescription: 'Incoming voice calls',
          importance: NotificationImportance.Max,
          locked: true,
          defaultRingtoneType: DefaultRingtoneType.Ringtone,
        ),
      ],
      debug: true,
    );

    // Get initial notification action is optional
    initialAction = await AwesomeNotifications()
        .getInitialNotificationAction(removeFromActionEvents: false);

    startListeningNotificationEvents();
  }

  static Future<void> showSimpleNotification({required String body}) async {
    if (!await AwesomeNotifications().isNotificationAllowed()) {
      AwesomeNotifications().requestPermissionToSendNotifications();
      return;
    }

    int notificationID = Random().nextInt(10000);
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: notificationID,
        channelKey: 'basic_channel',
        title: AppConstants.applicationTitle,
        body: body,
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }

  static Future<int> showVoiceCallNotification({
    required Uint8List iconData,
    required String callerName,
    required VoidCallback onAccept,
    String? payload,
  }) async {
    int notificationID = Random().nextInt(10000);

    var file = await createTempFile(iconData, "custom_icon");

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: notificationID,
        channelKey: 'voice_call_channel',
        title: AppConstants.applicationTitle,
        body: '$callerName is calling...',
        locked: true,
        fullScreenIntent: true,
        largeIcon: file.path,
        payload: {'caller': callerName},
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'ACCEPT',
          label: 'Accept',
          autoDismissible: true,
          actionType: ActionType.Default,
        ),
        NotificationActionButton(
          key: 'IGNORE',
          label: 'Ignore',
          autoDismissible: true,
          actionType: ActionType.Default,
        ),
      ],
    );

    return notificationID;
  }

  static Future<void> showInstantNotification({
    required Uint8List icon,
    required String body,
    required String summaryText,
    required String contentTitle,
    required String contentText,
    required ReplyCallback replyCallBack,
  }) async {
    int notificationID = Random().nextInt(10000);
    _replyToMessageCallback = replyCallBack;
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: notificationID,
        channelKey: 'basic_channel',
        title: contentTitle,
        body: contentText,
        summary: summaryText,
        notificationLayout: NotificationLayout.BigText,
      ),
      actionButtons: [
        NotificationActionButton(
          key: NotificationAction.actionReply.id,
          label: 'Reply',
          requireInputText: true,
        ),
        NotificationActionButton(
          key: NotificationAction.markAsRead.id,
          label: 'Mark as Read',
        ),
      ],
    );
  }

  ///  *********************************************
  ///     NOTIFICATION EVENTS LISTENER
  ///  *********************************************
  ///  Notifications events are only delivered after call this method
  static Future<void> startListeningNotificationEvents() async {
    AwesomeNotifications()
        .setListeners(onActionReceivedMethod: onActionReceivedMethod);
  }

  ///  *********************************************
  ///     NOTIFICATION EVENTS
  ///  *********************************************
  ///
  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    if (receivedAction.actionType == ActionType.SilentAction ||
        receivedAction.actionType == ActionType.SilentBackgroundAction) {
      // For background actions, you must hold the execution until the end
      print(
          'Message sent via notification input: "${receivedAction.buttonKeyInput}"');
      await executeLongTaskInBackground();
    } else {
      String actionId = receivedAction.buttonKeyPressed;
      print(actionId);

      NotificationAction na = NotificationAction.fromId(actionId);
      print(na);
      switch (na) {
        case NotificationAction.acceptVoiceCall:
          break;
        case NotificationAction.ignoreVoiceCall:
          // Do nothing
          break;
        case NotificationAction.endVoiceCall:
          break;
        case NotificationAction.actionReply:
          _replyToMessageCallback?.call(receivedAction.buttonKeyInput);
          _replyToMessageCallback = null;
          break;
        case NotificationAction.markAsRead:
          // To be implemented in the future
          break;
      }
    }
  }

  static Future<int> showPersistentEndVoiceCallNotification({
    required String callerName,
    required VoidCallback voiceCallEndCallback,
  }) async {
    int notificationID = Random().nextInt(10000);

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: notificationID,
        channelKey: 'voice_call_channel',
        title: AppConstants.applicationTitle,
        body: "In voice call with $callerName...",
        locked: true,
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'END_CALL',
          label: 'End Call',
          autoDismissible: true,
        ),
      ],
    );

    return notificationID;
  }

  static Future<void> cancelNotification(int notificationID) async {
    await AwesomeNotifications().cancel(notificationID);
  }

  ///  *********************************************
  ///     REQUESTING NOTIFICATION PERMISSIONS
  ///  *********************************************
  ///
  static Future<bool> displayNotificationRationale() async {
    bool userAuthorized = false;
    BuildContext context = NavigationService.currentContext;
    await showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: Text('Get Notified!',
                style: Theme.of(context).textTheme.titleLarge),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Image.asset(
                        'assets/images/animated-bell.gif',
                        height: MediaQuery.of(context).size.height * 0.3,
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                    'Allow Awesome Notifications to send you beautiful notifications!'),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  child: Text(
                    'Deny',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.red),
                  )),
              TextButton(
                  onPressed: () async {
                    userAuthorized = true;
                    Navigator.of(ctx).pop();
                  },
                  child: Text(
                    'Allow',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.deepPurple),
                  )),
            ],
          );
        });
    return userAuthorized &&
        await AwesomeNotifications().requestPermissionToSendNotifications();
  }

  ///  *********************************************
  ///     BACKGROUND TASKS TEST
  ///  *********************************************
  static Future<void> executeLongTaskInBackground() async {
        WidgetsFlutterBinding.ensureInitialized();

    await AppConstants.initialize();
    await NotificationService.init();
    timezones.initializeTimeZones();

    final settingsJson = SettingsJson();
    await settingsJson.loadSettingsJson();

    final DBConnection conn = ErmisDB.getConnection();
    ServerInfo serverInfo = await conn.getServerUrlLastUsed();

    Future<void> setupClient() async {
      try {
        await Client.instance().initialize(
          serverInfo.serverUrl,
          ServerCertificateVerification.ignore, // Since user connected once he has no issue connecting again
        );

        await Client.instance().readServerVersion();
        Client.instance().startMessageDispatcher();

        LocalAccountInfo? userInfo = await conn.getLastUsedAccount(serverInfo);
        if (userInfo == null) {
          return;
        }

        bool success = await Client.instance().attemptHashedLogin(userInfo);

        if (!success) {
          return;
        }

        await Client.instance().fetchUserInformation();
        Client.instance().commands!.setAccountStatus(ClientStatus.offline);
      } catch (e) {
        // Attempt to reinitialize client in case of failure
        await Future.delayed(const Duration(seconds: 30), setupClient);
      }
    }

    setupClient().whenComplete(() {
      final sessions = Client.instance().chatSessions!;
      for (final session in sessions) {
        Client.instance().commands!.fetchWrittenText(session.chatSessionIndex);
      }
    });

    AppEventBus.instance.on<WrittenTextEvent>().listen((event) async {
      ChatSession chatSession = event.chatSession;
      List<Message> messages = event.chatSession.messages;

      DBConnection conn = ErmisDB.getConnection();

      for (Message msg in messages) {
        int resultUpdate = await conn.insertChatMessage(
          serverInfo: serverInfo,
          message: msg,
        );

        if (resultUpdate > 0 && msg.clientID != Client.instance().clientID) {
          handleChatMessageNotificationBackground(chatSession, msg, settingsJson, (String text) {
            Client.instance().sendMessageToClient(text, chatSession.chatSessionIndex);
          });
        }

      }
    });

    AppEventBus.instance.on<ConnectionResetEvent>().listen((event) {
      // Attempt to re-establish connection in case of a connection reset
      Future.delayed(const Duration(seconds: 30), setupClient);
    });

    AppEventBus.instance.on<MessageReceivedEvent>().listen((event) {
      ChatSession chatSession = event.chatSession;
      Message msg = event.message;

      DBConnection conn = ErmisDB.getConnection();

      conn.insertChatMessage(
        serverInfo: Client.instance().serverInfo!,
        message: msg,
      );

      conn.insertUnreadMessage(serverInfo, msg.chatSessionID, msg.messageID);

      // Display notification only if message does not originate from one's self
      if (msg.clientID == Client.instance().clientID) return;

      handleChatMessageNotificationBackground(chatSession, msg, settingsJson, (String text) {
        Client.instance().sendMessageToClient(text, chatSession.chatSessionIndex);
      });
    });

    AppEventBus.instance.on<VoiceCallIncomingEvent>().listen((event) {
      NotificationService.showVoiceCallNotification(
          iconData: event.member.icon.profilePhoto,
          callerName: event.member.username,
          payload: jsonEncode({
            'chatSessionID': event.chatSessionID,
            'chatSessionIndex': event.chatSessionIndex,
            'member': jsonEncode(event.member.toJson()),
            'isInitiator': false,
          }),
          onAccept: () {
            // Won't get called since app will be brought from background to foreground
          });
    });

    debugPrint("BACKGROUND SERVICE INITIALIZED SUCCESSFULLY!");
    debugPrint("BACKGROUND SERVICE INITIALIZED SUCCESSFULLY!");
    debugPrint("BACKGROUND SERVICE INITIALIZED SUCCESSFULLY!");
    debugPrint("BACKGROUND SERVICE INITIALIZED SUCCESSFULLY!");
    debugPrint("BACKGROUND SERVICE INITIALIZED SUCCESSFULLY!");
    debugPrint("BACKGROUND SERVICE INITIALIZED SUCCESSFULLY!");
    debugPrint("BACKGROUND SERVICE INITIALIZED SUCCESSFULLY!");
    debugPrint("BACKGROUND SERVICE INITIALIZED SUCCESSFULLY!");
    debugPrint("BACKGROUND SERVICE INITIALIZED SUCCESSFULLY!");
    debugPrint("BACKGROUND SERVICE INITIALIZED SUCCESSFULLY!");
  }

  ///  *********************************************
  ///     NOTIFICATION CREATION METHODS
  ///  *********************************************
  ///
  static Future<void> createNewNotification() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) isAllowed = await displayNotificationRationale();
    if (!isAllowed) return;

    await AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: -1, // -1 is replaced by a random number
            channelKey: 'alerts',
            title: 'Huston! The eagle has landed!',
            body:
                "A small step for a man, but a giant leap to Flutter's community!",
            bigPicture: 'https://storage.googleapis.com/cms-storage-bucket/d406c736e7c4c57f5f61.png',
            largeIcon: 'https://storage.googleapis.com/cms-storage-bucket/0dbfcc7a59cd1cf16282.png',
            //'asset://assets/images/balloons-in-sky.jpg',
            notificationLayout: NotificationLayout.BigPicture,
            payload: {'notificationId': '1234567890'}),
        actionButtons: [
          NotificationActionButton(key: 'REDIRECT', label: 'Redirect'),
          NotificationActionButton(
              key: 'REPLY',
              label: 'Reply Message',
              requireInputText: true,
              actionType: ActionType.SilentAction),
          NotificationActionButton(
              key: 'DISMISS',
              label: 'Dismiss',
              actionType: ActionType.DismissAction,
              isDangerousOption: true)
        ]);
  }

  static Future<void> resetBadgeCounter() async {
    await AwesomeNotifications().resetGlobalBadge();
  }

  static Future<void> cancelNotifications() async {
    await AwesomeNotifications().cancelAll();
  }
}
*/
