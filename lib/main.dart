import 'package:flutter/material.dart';
import 'mysql/lianjie_chi.dart';
import 'ye_mian/zhu_yemian.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LianJieChi.chushihua();
  runApp(const WoDeApp());
}

class WoDeApp extends StatelessWidget {
  const WoDeApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HIS - Quan Pinyin',
      theme: ThemeData(useMaterial3: true),
      home: const ZhuYeMian(),
    );
  }
}
