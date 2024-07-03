
import 'package:calculator/button_values.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:decimal/decimal.dart';
class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String number1 ="";
  String operand ="";
  String number2 ="";

  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.minScrollExtent);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  double _maxScrollPosition = 0.0;

  bool lastPressedWasCalc = false;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          //output
          Expanded(
            child: Scrollbar(
              thumbVisibility: true,
              radius: const Radius.circular(5),
              thickness: 5,
              controller: _scrollController,
              child: Align(
                alignment: Alignment.bottomRight,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    reverse: true,
                    controller: _scrollController,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          "$number1$operand$number2".isEmpty?"0":
                          "$number1$operand$number2",
                          style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ),
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
          onTap: () =>onBtnTap(value),
          child: Center(
              child: Text(value , style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),)
          ),
        ),
      ),
    );
  }

  void onBtnTap(String value){
    clearError();
    if(value==Btn.del){
      delete();
      return;
    }
    if (value==Btn.clr){
      clearAll();
      return;
    }
    if (value==Btn.per){
      convertToPercentage();
      return;
    }
    if (value==Btn.calculate){
      calculate();
      return;
    }
    appendValue(value);
  }

  void calculate(){
    if (number1.isEmpty||operand.isEmpty||number2.isEmpty) return;
    Decimal num1 = Decimal.parse(number1);
    Decimal num2 = Decimal.parse(number2);
    Decimal res = Decimal.parse('0.0');
    switch (operand){
      case Btn.add:
        res = num1+num2;
        break;
      case Btn.subtract:
        res = num1-num2;
        break;
      case Btn.multiply:
        res = num1*num2;
        break;
      case Btn.divide:
        if (number2!=Btn.n0){
          res = (num1/num2).toDecimal(scaleOnInfinitePrecision: 10);
        }
        break;
      default:
    }
    setState(() {
      if (number2==Btn.n0&&operand==Btn.divide){
        number1 = "Error";
      } else {
        number1 = res.toString();
      }
      if(number1.endsWith(".0")){
        number1 = number1.substring(0,number1.length-2);
      }
      number2="";
      operand="";
      _maxScrollPosition = _scrollController.position.maxScrollExtent+1000;
    });
    _scrollController.animateTo(
      _maxScrollPosition,
      duration: const Duration(milliseconds: 500),
      curve: Curves.ease,
    );
    lastPressedWasCalc = true;
  }

  void clearError(){
    if (number1=="Error"){
      setState(() {
        number1="0";
        number2="";
        operand="";
      });
      return;
    }
  }

  void convertToPercentage(){
    if (number1.isNotEmpty&&operand.isNotEmpty&&number2.isNotEmpty){
      calculate();
    }
    if (operand.isNotEmpty){
      setState(() {
        number1="Error";
        number2="";
        operand="";
      });
      return;
    }
    Decimal num = Decimal.parse(number1);
    Decimal per = Decimal.parse('100');
    Decimal res = (num/per).toDecimal();
    setState(() {
      number1 =res.toString();
      operand="";
      number2="";
    });
  }

  void clearAll(){
    setState(() {
      number1="";
      number2="";
      operand="";
    });
  }

  void delete(){
    clearError();
    if (number2.isNotEmpty){
      number2=number2.substring(0,number2.length-1);
    } else if (operand.isNotEmpty){
      operand="";
    } else if(number1.isNotEmpty){
      number1=number1.substring(0,number1.length-1);
    }
    setState(() {

    });
  }



  void appendValue (String value){
    clearError();
    if (number1.isEmpty&&value==Btn.n0) return;
    if (number1.isEmpty&&value==Btn.add) return;
    if (value!=Btn.dot && int.tryParse(value)==null){
      if (operand.isNotEmpty&&number2.isNotEmpty){
        calculate();
      }
      if (number1.endsWith(".")&&number2.isEmpty){
        number1+="0";
      }
      if (number1.isEmpty&&value==Btn.subtract) {
        number1 = "-0";
      }else if(number1.isNotEmpty&&(operand==Btn.multiply||operand==Btn.divide)&&number2.isEmpty&&value==Btn.subtract){
          number2 = value;
      }
      else {
        if (number1!="Error") {
          operand = value;
        }
      }
    } else if(number1.isEmpty || operand.isEmpty){
      if (value==Btn.dot&&number1.contains(Btn.dot)) return;
      if (value==Btn.dot&&(number1.isEmpty || number1==Btn.n0)) {
        value = "0.";
      }
      if (lastPressedWasCalc&&value==Btn.dot){
        number1 = "0.";
        lastPressedWasCalc = false;
      } else if (lastPressedWasCalc){
        if(value=="0"){
          number1="";
        } else {
          number1 = value;
        }
        lastPressedWasCalc = false;
      } else {
        if (number1=="-0"&&value!=Btn.dot){
          number1= "-$value";
        } else if (number1=="-0"&&value==Btn.dot) {
          number1= "-0$value";
        } else {
          number1+=value;
        }
      }
    } else if(number2.isEmpty || operand.isNotEmpty){
      if (value==Btn.dot&&number2.contains(Btn.dot)) return;
      if (value==Btn.dot&&(number2.isEmpty || number2==Btn.n0)) {
        value = "0.";
      }
      number2 += value;
    }
    setState(() {
      _maxScrollPosition = _scrollController.position.minScrollExtent;
    });
    _scrollController.animateTo(
      _maxScrollPosition,
      duration: const Duration(milliseconds: 200),
      curve: Curves.ease,
    );
  }

  Color getBtnColor(value){
    return [Btn.del,Btn.clr].contains(value)?Colors.blueGrey
        : [
      Btn.per,Btn.add,Btn.multiply,Btn.divide,Btn.subtract,Btn.calculate
    ].contains(value)?Colors.orange:Colors.black87;
  }
}
