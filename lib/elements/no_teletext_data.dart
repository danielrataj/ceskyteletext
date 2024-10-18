import 'package:flutter/material.dart';
import 'package:ceskyteletext/model/app_state.dart' as model;
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class NoTelextData extends StatelessWidget {
  const NoTelextData({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.sentiment_dissatisfied, size: 100),
          Text('Zkontrolujte prosím své internetové připojení.',
              style: TextStyle(fontSize: 20.sp), textAlign: TextAlign.center),
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
          ),
          ElevatedButton.icon(
              onPressed: () {
                Provider.of<model.AppState>(context, listen: false).clear();
              },
              icon: const Icon(Icons.refresh),
              label: Text(
                'začít znovu',
                style: TextStyle(fontSize: 12.sp),
              ))
        ],
      ),
    );
  }
}
