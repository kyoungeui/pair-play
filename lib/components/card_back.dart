import 'package:pairplay/components/constants.dart';
import 'package:flutter/material.dart';

class CardBack extends StatelessWidget {
  final double size;
  final Widget? child;

  const CardBack({Key? key, this.size = 2, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: CARD_WIDTH * size,
      height: CARD_HEIGHT * size,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.inversePrimary,
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: child != null ? child : Container(), 
    );
  }
}