import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('О нас'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Добро пожаловать на наш сайт! Мы команда энтузиастов, преданная созданию удивительных вещей и предоставлению вам лучшего опыта. Наша миссия - делать вашу жизнь лучше и интереснее через технологии и инновации.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            SizedBox(height: 16),
            Text(
              'Мы стремимся к качеству, творчеству и инновациям в каждом аспекте нашей работы. Если у вас есть вопросы или предложения, не стесняйтесь связаться с нами. Мы всегда готовы услышать вас!',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
