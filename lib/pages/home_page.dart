import 'package:chat_app_firebase/models/user_profile.dart';
import 'package:chat_app_firebase/pages/chat_page.dart';
import 'package:chat_app_firebase/services/Alert_service.dart';
import 'package:chat_app_firebase/services/auth_service.dart';
import 'package:chat_app_firebase/services/database_service.dart';
import 'package:chat_app_firebase/services/navigation_service.dart';
import 'package:chat_app_firebase/widgets/chat_tile.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GetIt _getIt = GetIt.instance;
  late AuthService _authService;
  late NavigationService _navigationService;
  late AlertService _alertService;
  late DatabaseService _databaseService;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
    _alertService = _getIt.get<AlertService>();
    _databaseService = _getIt.get<DatabaseService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Messages"),
        actions: [
          IconButton(
              onPressed: () async {
                final result = await _authService.logout();
                if (result) {
                  _alertService.showToast(
                      text: "Successfully logged out!", icon: Icons.check);
                  _navigationService.pushReplacementNamed('/login');
                } else {
                  _alertService.showToast(
                      text: "Failed to logout Please Try again ",
                      icon: Icons.error);
                }
              },
              icon: const Icon(Icons.logout)),
        ],
      ),
      body: _buildUi(),
    );
  }

  Widget _buildUi() {
    return SafeArea(
        child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 20,
      ),
      child: _chatList(),
    ));
  }

  Widget _chatList() {
    return StreamBuilder(
      stream: _databaseService.getUserProfiles(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text("Unable to load the data"),
          );
        }
        print(snapshot.data);
        if (snapshot.hasData && snapshot.data != null) {
          final users = snapshot.data!.docs;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              UserProfile user = users[index].data();
              return ChatTile(
                  userProfile: user,
                  onTap: () async {
                    final chatExist = await _databaseService.checkChatExist(
                        _authService.user!.uid, user.uid!);
                    print("jwbef");
                    print(chatExist);

                    if (!chatExist) {
                      await _databaseService.createNewChat(
                          _authService.user!.uid, user.uid!);
                    }
                    _navigationService.push(MaterialPageRoute(
                      builder: (context) {
                        return ChatPage(chatUser: user);
                      },
                    ));
                  });
            },
          );
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
