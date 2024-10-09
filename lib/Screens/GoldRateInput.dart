import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:leelacasting/CommonWidgets/InputField.dart';
import 'package:leelacasting/Utilites/Colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoldRateInput extends StatefulWidget {
  const GoldRateInput({super.key});

  @override
  State<GoldRateInput> createState() => _GoldRateInputState();
}

class _GoldRateInputState extends State<GoldRateInput> {
  @override
  Widget build(BuildContext context) {
    TextEditingController ornamentWeightCtrl = TextEditingController();
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    bool isLoading = false;

    saveGoldRate() async {
      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        double ornamentWeight_ = double.parse(ornamentWeightCtrl.text);
        await prefs.setDouble('todayGoldPrice', ornamentWeight_);
      } catch (e) {
        print("error in set : $e");
      }
    }

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: AppColors.secondaryClr,
          ),
          child: AlertDialog(
            title: const Text("Enter Today's gold rate"),
            actions: <Widget>[
              buildTextFormField(
                labelText: "Gold Rate",
                keyboardType: TextInputType.number,
                controller: ornamentWeightCtrl,
              ),
              TextButton(
                onPressed: () async {
                  setState(() {
                    isLoading = true;
                  });
                  await saveGoldRate();
                  setState(() {
                    isLoading = true;
                  });
                  Navigator.pop(context); // Close the drawer
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
        Visibility(
          visible: isLoading,
          child: SpinKitFadingCube(
            size: 60,
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
        ),
      ],
    );
  }
}
