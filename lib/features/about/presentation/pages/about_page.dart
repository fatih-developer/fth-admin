import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            const Center(
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Color(0x22FF6B00),
                child: Icon(
                  Icons.info_outline,
                  size: 60,
                  color: Color(0xFFFF6B00),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Hakkında',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            const Text(
              'FTH Admin Paneli, yönetici işlemlerinizi kolaylaştırmak için tasarlanmıştır. Bu uygulama Flutter ile geliştirilmiştir ve modern kullanıcı arayüzü prensiplerine uygun olarak tasarlanmıştır.',
              style: TextStyle(color: Colors.grey, height: 1.6),
            ),
            const SizedBox(height: 24),
            const Text(
              'Versiyon Bilgisi',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'v1.0.0',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
