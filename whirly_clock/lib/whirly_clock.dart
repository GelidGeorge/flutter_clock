// Copyright 2020 George Levin D'souza. All rights reserved.
// Use of this source code is governed by a Apache-2.0 license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:vector_math/vector_math_64.dart' show radians;
import 'package:whirly_clock/whirly_dial.dart';
import 'package:whirly_clock/whirly_hand.dart';

/// Total distance traveled by a second or a minute hand, each second or minute,
/// respectively.
final radiansPerTick = radians(360 / 60);

/// Total distance traveled by an hour hand, each hour, in radians.
final radiansPerHour = radians(360 / 12);

class WhirlyClock extends StatefulWidget {
  const WhirlyClock(this.model, this.dependOnTime);

  final ClockModel model;
  final bool dependOnTime;

  @override
  _WhirlyClockState createState() => _WhirlyClockState();
}

class _WhirlyClockState extends State<WhirlyClock>
    with SingleTickerProviderStateMixin {
  // Animation Duration.
  final int _animationDuration = 3;

  bool _heightFallacy;

  // Device parameter and screen config.
  double _width;
  double _height;
  double _xDivs;
  double _yDivs;
  double startAngle = radians(270);

  ThemeData customTheme;

  String time;

  var _now = DateTime.now();
  var _greetings = '';
  var _temperature = '';
  var _temperatureRange = '';
  var _condition = '';
  var _location = '';

  Timer _timer;

  // WhirlyClock Background Color.
  Color _clockColor = Color(0xFF2E4482);

  // Greet Animations Controller.
  AnimationController _clockGreeter;

  // Animations to generate clock greetings.
  Animation<double> _rightEyeSize;
  Animation<Offset> _leftEyeAnimation;
  Animation<Offset> _rightEyeAnimation;
  Animation<double> _noseAnimation;
  Animation<Offset> _smileAnimation;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    _updateTime();
    _updateModel();
    _clockGreeter = AnimationController(
      duration: Duration(seconds: _animationDuration),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(WhirlyClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_clockGreeter.isAnimating) {
      _initializer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    _clockGreeter.dispose();
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      _temperature = widget.model.temperatureString;
      _temperatureRange = '(${widget.model.low} - ${widget.model.highString})';
      _condition = widget.model.weatherString;
      _location = widget.model.location;
    });
  }

  void _updateTime() {
    setState(() {
      _now = DateTime.now();
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _now.millisecond),
        _updateTime,
      );
    });
    _clockGreet();
  }

  double _hour() {
    return _now.hour > 12
        ? _now.subtract(Duration(hours: 12)).hour * radiansPerHour
        : _now.hour * radiansPerHour;
  }

  double _minute() {
    return _now.minute * radiansPerTick;
  }

  double _second() {
    return _now.second * radiansPerTick;
  }

  void _clockGreet() {
    // Conditionally starts greet animations.
    if (_now.hour == 5 && _now.minute == 0 && _now.second == 0) {
      _clockGreeter.reset();
      _initializer();
    }
    if (_now.hour == 12 && _now.minute == 0 && _now.second == 0) {
      _clockGreeter.reset();
      _initializer();
    }
    if (_now.hour == 17 && _now.minute == 0 && _now.second == 0) {
      _clockGreeter.reset();
      _initializer();
    }
    if (_now.hour == 20 && _now.minute == 0 && _now.second == 0) {
      _clockGreeter.reset();
      _initializer();
    }
  }

  // Initializes and triggers the greet animations and sets greet messages.
  _initializer() {
    _rightEyeSize = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.79, end: 0.648),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.648, end: 0.79),
        weight: 20,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _clockGreeter,
        curve: Curves.slowMiddle,
      ),
    );
    _leftEyeAnimation = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween<Offset>(
            begin: Offset(radians(270), _minute()),
            end: Offset(radians(231.25 + 360), radians(10))),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(
            begin: Offset(radians(231.25 + 360), radians(10)),
            end: Offset(radians(270), _minute())),
        weight: 20,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _clockGreeter,
        curve: Curves.slowMiddle,
      ),
    );
    _rightEyeAnimation = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween<Offset>(
            begin: Offset(radians(270), _second()),
            end: Offset(radians(299.75 - 360), radians(8))),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: Offset(radians(299.75 - 360), radians(8)),
          end: Offset(
              radians(270), _second() + (_animationDuration * radiansPerTick)),
        ),
        weight: 20,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _clockGreeter,
        curve: Curves.slowMiddle,
      ),
    );
    _smileAnimation = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween<Offset>(
            begin: Offset(radians(270), _hour()),
            end: Offset(radians(405), radians(90))),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(
            begin: Offset(radians(405), radians(90)),
            end: Offset(radians((270 + 360).toDouble()), _hour())),
        weight: 20,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _clockGreeter,
        curve: Curves.slowMiddle,
      ),
    );
    _noseAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.5, end: 0.15),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.15, end: 0.5),
        weight: 20,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _clockGreeter,
        curve: Curves.slowMiddle,
      ),
    );
    // Conditionally changes clock color and greet message.
    setState(() {
      if (_now.hour >= 5 && _now.minute >= 0 && _now.hour <= 12) {
        _greetings = 'Good Morning';
        if (widget.dependOnTime) {
          _clockColor = Color(0xFF68CEBF);
        }
      }
      if (_now.hour >= 12 && _now.minute >= 0 && _now.hour <= 17) {
        _greetings = 'Good Afternoon';
        if (widget.dependOnTime) {
          _clockColor = Color(0xFFFF8D00);
        }
      }
      if (_now.hour >= 17 && _now.minute >= 0 && _now.hour <= 20) {
        _greetings = 'Good Evening';
        if (widget.dependOnTime) {
          _clockColor = Color(0xFF882255);
        }
      }
      if ((_now.hour >= 20 && _now.minute >= 0) ||
          (_now.hour >= 0 && _now.minute >= 0 && _now.hour < 5)) {
        _greetings = 'Good Night';
        if (widget.dependOnTime) {
          _clockColor = Color(0xFF2E4482);
        }
      }
    });
    _clockGreeter.forward();
  }

  @override
  Widget build(BuildContext context) {
    _width = MediaQuery.of(context).size.width -
        MediaQuery.of(context).padding.left -
        MediaQuery.of(context).padding.right;
    _height = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;
    _xDivs = _width / 100;
    _yDivs = _height / 100;
    _heightFallacy = (_yDivs / _xDivs) >= (5 / 3) ? true : false;

    customTheme = Theme.of(context).brightness == Brightness.light
        ? Theme.of(context).copyWith(
            // Minute hand.
            highlightColor: Color(0xFF0F9D58),
            // Second hand.
            accentColor: Color(0xFFF4B400),
            // Hour hand.
            primaryColor: Color(0xFFDB4437),
            // Dial
            buttonColor: Color(0xFF4285F4),
            // Clock Background
            focusColor: _clockColor,
            // Greet Color
            hoverColor: _clockColor,
            // Background Color,
            backgroundColor: Color(0xFFFFFFFF),
          )
        : Theme.of(context).copyWith(
            highlightColor: Colors.grey[300],
            accentColor: Colors.grey[500],
            primaryColor: Colors.grey[700],
            buttonColor: Colors.grey[600],
            focusColor: Colors.grey[800],
            hoverColor: _clockColor,
            backgroundColor: Colors.black,
          );

    time = (widget.model.is24HourFormat)
        ? DateFormat.Hms().format(DateTime.now())
        : DateFormat.jms().format(DateTime.now());

    return Semantics.fromProperties(
      properties: SemanticsProperties(
        label: 'Analogue and digital clock with time $time',
        value: time,
      ),
      child: Container(
        padding: EdgeInsets.all(
          _heightFallacy ? _yDivs : _xDivs,
        ),
        color: customTheme.backgroundColor,
        child: AnimatedBuilder(
          animation: _clockGreeter,
          builder: _buildClock,
          child: Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              height: _heightFallacy ? _xDivs * 56 : _yDivs * 100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  timeInfo(),
                  weatherInfo(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget iconBox(
      bool heightFallacy, IconData icon, Color bgColor, Color color) {
    return Container(
      margin: EdgeInsets.all(3),
      width: heightFallacy ? _xDivs * 6 : _yDivs * 9,
      height: heightFallacy ? _xDivs * 6 : _yDivs * 9,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(
          heightFallacy ? _xDivs * 6 / 2 : _yDivs * 9 / 2,
        ),
      ),
      child: Icon(
        icon,
        color: color ?? Colors.blueGrey,
        size: heightFallacy ? _xDivs * 3.5 : _yDivs * 4.5,
      ),
    );
  }

  // Method to color code parts of string.
  TextSpan _timeFilter(int start, int end, [Color color]) {
    return TextSpan(
      text: time.substring(
        start,
        end,
      ),
      style: TextStyle(
        color: color,
      ),
    );
  }

  // Method which builds Text to display time.
  Widget timeInfo() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontFamily: 'Audiowide',
              fontSize: widget.model.is24HourFormat
                  ? _heightFallacy ? _xDivs * 7.2 : _yDivs * 13
                  : _heightFallacy ? _xDivs * 6 : _yDivs * 11.5,
              color: customTheme.buttonColor,
            ),
            children: (time.length == 8)
                ? [
                    _timeFilter(0, 2, customTheme.primaryColor),
                    _timeFilter(2, 3),
                    _timeFilter(3, 5, customTheme.accentColor),
                    _timeFilter(5, 6),
                    _timeFilter(6, 8, customTheme.highlightColor),
                  ]
                : (time.length < 11)
                    ? [
                        _timeFilter(0, 1, customTheme.primaryColor),
                        _timeFilter(1, 2),
                        _timeFilter(2, 4, customTheme.accentColor),
                        _timeFilter(4, 5),
                        _timeFilter(5, 7, customTheme.highlightColor),
                        _timeFilter(7, 10),
                      ]
                    : [
                        _timeFilter(0, 2, customTheme.primaryColor),
                        _timeFilter(2, 3),
                        _timeFilter(3, 5, customTheme.accentColor),
                        _timeFilter(5, 6),
                        _timeFilter(6, 8, customTheme.highlightColor),
                        _timeFilter(8, 11),
                      ],
          ),
        ),
        SizedBox(
          height: _heightFallacy ? _xDivs * 2.5 : _yDivs * 2.5,
        ),
        Text(
          '$_greetings',
          style: TextStyle(
            fontFamily: 'Audiowide',
            color: customTheme.focusColor,
            fontSize: _heightFallacy ? _xDivs * 4 : _yDivs * 7,
          ),
        ),
      ],
    );
  }

  // Method which builds Text and icons to display weather information.
  Widget weatherInfo() {
    return DefaultTextStyle(
      style: TextStyle(
        fontFamily: 'Audiowide',
        fontSize: _xDivs * 3,
        color: customTheme.buttonColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  _temperature,
                ),
              ),
              iconBox(
                _heightFallacy,
                FontAwesomeIcons.temperatureHigh,
                customTheme.highlightColor,
                customTheme.backgroundColor,
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  _temperatureRange,
                ),
              ),
              iconBox(
                _heightFallacy,
                FontAwesomeIcons.thermometer,
                customTheme.highlightColor,
                customTheme.backgroundColor,
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  _condition,
                ),
              ),
              iconBox(
                _heightFallacy,
                FontAwesomeIcons.cloudSunRain,
                customTheme.highlightColor,
                customTheme.backgroundColor,
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(_location),
              ),
              iconBox(
                _heightFallacy,
                FontAwesomeIcons.mapPin,
                customTheme.highlightColor,
                customTheme.backgroundColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Method which builds the clock character.
  Widget _buildClock(context, child) {
    return Stack(
      alignment: Alignment(-1, 0),
      children: [
        Container(
          height: _heightFallacy ? _xDivs * 56 : _yDivs * 100,
          width: _heightFallacy ? _xDivs * 56 : _yDivs * 100,
          decoration: BoxDecoration(
            color: customTheme.focusColor,
            borderRadius: BorderRadius.circular(
              _heightFallacy ? _xDivs * (56 / 2) : _yDivs * 50,
            ),
          ),
          child: WhirlyDial(
            color: customTheme.buttonColor,
            lineWidth: 0.025,
            handSize: _noseAnimation.value,
            isNose: _clockGreeter.isAnimating ? false : true,
          ),
        ),
        Container(
          height: _heightFallacy ? _xDivs * 56 : _yDivs * 100,
          width: _heightFallacy ? _xDivs * 56 : _yDivs * 100,
          child: WhirlyHand(
            startAngle: _clockGreeter.isAnimating
                ? _smileAnimation.value.dx
                : startAngle,
            sweepAngle:
                _clockGreeter.isAnimating ? _smileAnimation.value.dy : _hour(),
            color: customTheme.primaryColor,
            lineWidth: _heightFallacy ? _xDivs * 1.4 : _yDivs * 2.4,
            handSize: 0.55,
          ),
        ),
        Container(
          height: _heightFallacy ? _xDivs * 56 : _yDivs * 100,
          width: _heightFallacy ? _xDivs * 56 : _yDivs * 100,
          child: WhirlyHand(
            startAngle: _clockGreeter.isAnimating
                ? _leftEyeAnimation.value.dx
                : startAngle,
            sweepAngle: _clockGreeter.isAnimating
                ? _leftEyeAnimation.value.dy
                : _minute(),
            color: customTheme.accentColor,
            lineWidth: _heightFallacy ? _xDivs * 3 : _yDivs * 4,
            handSize: 0.648,
          ),
        ),
        Container(
          height: _heightFallacy ? _xDivs * 56 : _yDivs * 100,
          width: _heightFallacy ? _xDivs * 56 : _yDivs * 100,
          child: WhirlyHand(
            startAngle: _clockGreeter.isAnimating
                ? _rightEyeAnimation.value.dx
                : startAngle,
            sweepAngle: _clockGreeter.isAnimating
                ? _rightEyeAnimation.value.dy
                : _second(),
            color: customTheme.highlightColor,
            lineWidth: _heightFallacy ? _xDivs * 3.5 : _yDivs * 5.5,
            handSize: _clockGreeter.isAnimating ? _rightEyeSize.value : 0.79,
          ),
        ),
        child,
      ],
    );
  }
}
