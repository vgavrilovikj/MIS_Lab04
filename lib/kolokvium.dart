import 'package:flutter/material.dart';

class Kolokvium extends StatelessWidget {

  final Color _textColor2;
  String _name, _date, _time;

  Kolokvium(this._name, this._date, this._time, this._textColor2);

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 2,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.only(left: 5, right: 5),
                margin: const EdgeInsets.only(left: 10, right: 10),
                child: Text(
                  _name,
                  style: TextStyle(
                      fontSize: 20,
                      color: _textColor2,
                      fontWeight: FontWeight.bold
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(5),
                margin: const EdgeInsets.only(left: 10, right: 10),
                child: Text(
                  '$_date $_time',
                  style: TextStyle(color: Colors.grey[400])
                )
              ),
            ])
    );

  }

}