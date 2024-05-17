import 'package:flutter/material.dart';
import 'package:june/june.dart';

import '../../../extensions/extensions.dart';
import '../../../states/common_state.dart';
import '../../../utils/methods.dart';
import '../../../utils/values.dart';

class SampleScreen extends StatelessWidget {
  const SampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Widget textBuilder(CommonState cs) {
      final String ct;
      switch (cs.count) {
        case 1:
          ct = 'Once';
          break;
        case 2:
          ct = 'Twice';
          break;
        case 3:
          ct = 'Thrice';
          break;
        default:
          ct = '${cs.count} times';
      }
      cs.count.factorial.jot();
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('This Button has been pressed $ct'),
          Text(cs.count.factorial.string)
        ],
      );
    }

    return Scaffold(
        floatingActionButton: FloatingActionButton(onPressed: () {
          // jot([4,2,1,9,5].getNthLargest(3));
          for (int i = 1; i < 10000000; i++) {
            i.isPerfect ? i.jot() : doNothing();
          }
        }),
        appBar: AppBar(title: const Text('Biometric Authentication'), actions: [
          IconButton(onPressed: cm.increment, icon: const Icon(Icons.add)),
          IconButton(onPressed: cm.decrement, icon: const Icon(Icons.remove))
        ]),
        body:
            JuneBuilder<CommonState>(obtainCommonState, builder: textBuilder));
  }
}
