import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:oauth2_client/oauth2_client.dart';
import 'package:oauth2_client/oauth2_helper.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

void main() {
  HttpOverrides.global = MyHttpOverrides();
  //runApp(const MyApp());
  runApp(
    ChangeNotifierProvider(
      create: (_) => Session(),
      child: MyApp(),
    ),
  );
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          ((X509Certificate cert, String host, int port) {
        return true;
      });
  }
}

class Session with ChangeNotifier {
  late Map<String, dynamic> _user;

  Map<String, dynamic> get user => _user;

  void updateToken(Map<String, dynamic> newValue) {
    _user = newValue;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => HomePage();
}

class HomePage extends State<MyHomePage> {
  final customUriScheme = 'app.poliwangi.sit';
  final redirectUri = 'app.poliwangi.sit://oauth2redirect';
  final clientId = '';
  final clientSecret = '';

  final userUrlData = 'https://sso.poliwangi.ac.id/api/user';
  final authorizeUrl = 'https://sso.poliwangi.ac.id/oauth/authorize';
  final tokenUrl = 'https://sso.poliwangi.ac.id/oauth/token';
  final refreshToken = 'test_refresh_token';
  final accessToken = 'test_access_token';

  void _showPopup(BuildContext context, String pesan) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Halo!'),
          content: Text(pesan),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  Future<bool> loginSSO(BuildContext context) async {
    bool sukses = false;
    var helper = OAuth2Helper(
      OAuth2Client(
        authorizeUrl: authorizeUrl,
        redirectUri: redirectUri,
        tokenUrl: tokenUrl,
        customUriScheme: customUriScheme,
      ),
      grantType: OAuth2Helper.authorizationCode,
      clientId: clientId,
      clientSecret: clientSecret,
    );
    //print(userUrlData + " <----");
    var tknResp = await helper.get(userUrlData);
    Map<String, dynamic> user = jsonDecode(tknResp.body);
    if (user != null) {
      Provider.of<Session>(context, listen: false).updateToken(user);
      sukses = true;
    }

    return sukses;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Logo dari asset
            Image.asset(
              'assets/img/logo.png', // Ganti dengan path logo Anda
              width: 150,
            ),
            SizedBox(height: 20),
            // Tombol
            ElevatedButton(
              onPressed: () async {
                if (await loginSSO(context)) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SecondPage()),
                  );
                } else {
                  _showPopup(context, "Login gagal");
                }
              },
              child: Text('Login SSO'),
            ),
          ],
        ),
      ),
    );
  }
}

class SecondPage extends StatelessWidget {
  String getDetailUser(BuildContext context) {
    String detail = "";

    var user = Provider.of<Session>(context, listen: false).user;
    String nama = user['name'];
    String username = user['username'];
    int unit = user['unit'];
    int staff = user['staff'];
    detail =
        '$detail nama = $nama \n username = $username\n unit = $unit\n staff = $staff';
    return detail;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Halaman Kedua'),
      ),
      body: Center(
        child: Text(
          getDetailUser(context),
          style: TextStyle(fontSize: 24.0),
        ),
      ),
    );
  }
}
