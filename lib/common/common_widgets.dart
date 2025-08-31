import 'package:flutter/material.dart';

class MokuaiHeader extends StatelessWidget {
  const MokuaiHeader(
    this.biaoti, {
    super.key,
    this.caozuoAnniu,
    this.neibuPadding,
  });
  final String biaoti;
  final List<Widget>? caozuoAnniu;
  final EdgeInsetsGeometry? neibuPadding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          neibuPadding ??
          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Row(
        children: [
          Text(biaoti, style: Theme.of(context).textTheme.titleMedium),
          const Spacer(),
          ...?caozuoAnniu,
        ],
      ),
    );
  }
}

Widget jianju12() => const SizedBox(width: 12, height: 12);
InputDecoration biaoqianInput(String biaoqian) =>
    InputDecoration(labelText: biaoqian, border: const OutlineInputBorder());
