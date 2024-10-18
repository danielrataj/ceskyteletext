import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class NoInternetConnection extends StatelessWidget {
  const NoInternetConnection({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 55.h,
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off, size: 40.sp, color: Theme.of(context).colorScheme.error,),
            Text('Zkontrolujte prosím své internetové připojení.', style: TextStyle(fontSize: 20.sp, color: Theme.of(context).colorScheme.error), textAlign: TextAlign.center),
          ]
        ),
      ),
    );
  }
}
