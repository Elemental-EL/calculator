import 'package:calculator/button_values.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          //output
          Expanded(
            child: SingleChildScrollView(
              reverse: true,
              child: Container(
                alignment: Alignment.bottomRight,
                padding: const EdgeInsets.all(16),
                child: const Text(
                  "0",
                  style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ),
          ),
          
          //input
          Wrap(
            children: Btn.buttonValues
                .map(
                  (value) => SizedBox(
                    width: value==Btn.n0?screenSize.width/2:(screenSize.width/4) ,
                    height: screenSize.width/5 ,
                    child: buildButton(value),
                  ),
                )
                .toList(),
          )
        ],),
      ),
    );
  }

  Widget buildButton(value){
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Material(
        color: getBtnColor(value),
        clipBehavior: Clip.hardEdge,
        shape: OutlineInputBorder(
          borderSide: const BorderSide(
              color: Colors.white24
          ),
          borderRadius: BorderRadius.circular(25),
        ),
        child: InkWell(
          onTap: () {},
          child: Center(
              child: Text(value , style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),)
          ),
        ),
      ),
    );
  }

  Color getBtnColor(value){
    return [Btn.del,Btn.clr].contains(value)?Colors.blueGrey
        : [
      Btn.per,Btn.add,Btn.multiply,Btn.divide,Btn.subtract,Btn.calculate
    ].contains(value)?Colors.orange:Colors.black87;
  }
}
