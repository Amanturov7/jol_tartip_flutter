import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactPage extends StatelessWidget {
  final String phoneNumber = "0706222772";
  final String email = "edi.amanturov2@gmail.com";
  final String telegramUsername = "joltartipkg";
  final String instagramUsername = "joltartipkg";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('contact'.tr()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            leading: Icon(Icons.phone, color: Colors.blue),
            title: Text('Phone'),
            subtitle: Text(phoneNumber),
            onTap: () => _makePhoneCall(phoneNumber),
          ),
          ListTile(
            leading: Icon(Icons.email, color: Colors.red),
            title: Text('Email'),
            subtitle: Text(email),
            onTap: () => _sendEmail(email),
          ),
          ListTile(
            leading: Icon(Icons.telegram, color: Colors.blue),
            title: Text('Telegram'),
            subtitle: Text('@$telegramUsername'),
            onTap: () => _openTelegram(telegramUsername),
          ),
          ListTile(
            leading: Icon(Icons.camera_alt, color: Colors.purple),
            title: Text('Instagram'),
            subtitle: Text('@$instagramUsername'),
            onTap: () => _openInstagram(instagramUsername),
          ),
        ],
      ),
    );
  }

  void _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunch(launchUri.toString())) {
      await launch(launchUri.toString());
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }

  void _sendEmail(String email) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    if (await canLaunch(emailLaunchUri.toString())) {
      await launch(emailLaunchUri.toString());
    } else {
      throw 'Could not launch $email';
    }
  }

  void _openTelegram(String username) async {
    final String telegramAppUrl = 'tg://resolve?domain=$username';
    final String telegramWebUrl = 'https://t.me/$username';
    if (await canLaunch(telegramAppUrl)) {
      await launch(telegramAppUrl);
    } else {
      await launch(telegramWebUrl);
    }
  }

  void _openInstagram(String username) async {
    final String instagramAppUrl = 'instagram://user?username=$username';
    final String instagramWebUrl = 'https://www.instagram.com/$username';
    if (await canLaunch(instagramAppUrl)) {
      await launch(instagramAppUrl);
    } else {
      await launch(instagramWebUrl);
    }
  }
}
