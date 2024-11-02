import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SpinKitFadingCube(
        size: 75,
        itemBuilder: (context, index) {
          final colors = [Colors.orangeAccent, Colors.black];
          final color = colors[index % colors.length];

          return DecoratedBox(
            decoration: BoxDecoration(
              color: color,
            ),
          );
        },
      ),
    );
  }
}


class CustomLoadingWidget extends StatelessWidget {
  final Function toggleLoading;

  const CustomLoadingWidget({required this.toggleLoading, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    toggleLoading(); // Call the function to set isLoading to true
    return const Center(child: LoadingIndicator());
  }
}
