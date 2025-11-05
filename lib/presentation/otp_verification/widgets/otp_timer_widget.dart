import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';


class OtpTimerWidget extends StatefulWidget {
  final int duration;
  final bool canResend;
  final bool isResendLoading;
  final VoidCallback onResend;
  final VoidCallback onTimerComplete;

  const OtpTimerWidget({
    Key? key,
    required this.duration,
    required this.canResend,
    required this.isResendLoading,
    required this.onResend,
    required this.onTimerComplete,
  }) : super(key: key);

  @override
  State<OtpTimerWidget> createState() => _OtpTimerWidgetState();
}

class _OtpTimerWidgetState extends State<OtpTimerWidget>
    with TickerProviderStateMixin {
  Timer? _timer;
  int _currentSeconds = 0;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _currentSeconds = widget.duration;

    _animationController = AnimationController(
      duration: Duration(seconds: widget.duration),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ));

    if (!widget.canResend) {
      _startTimer();
    }
  }

  @override
  void didUpdateWidget(OtpTimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Restart timer if duration changes and can't resend
    if (oldWidget.duration != widget.duration ||
        (oldWidget.canResend && !widget.canResend)) {
      _currentSeconds = widget.duration;
      if (!widget.canResend) {
        _startTimer();
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _animationController.forward();

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentSeconds > 0) {
        setState(() {
          _currentSeconds--;
        });
      } else {
        timer.cancel();
        _animationController.reset();
        widget.onTimerComplete();
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(1, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Timer Display
        if (!widget.canResend) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.access_time,
                size: 18.w,
                color: Colors.grey[600],
              ),
              SizedBox(width: 8.w),
              Text(
                'Code expires in ${_formatTime(_currentSeconds)}',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Progress Indicator
          Container(
            width: double.infinity,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(2.w),
            ),
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _animation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _currentSeconds > 30
                          ? Theme.of(context).primaryColor
                          : _currentSeconds > 10
                              ? Colors.orange
                              : Colors.red,
                      borderRadius: BorderRadius.circular(2.w),
                    ),
                  ),
                );
              },
            ),
          ),
        ],

        // Resend Section
        SizedBox(height: 24.h),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Didn\'t receive the code? ',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[600],
              ),
            ),
            GestureDetector(
              onTap: widget.canResend && !widget.isResendLoading
                  ? widget.onResend
                  : null,
              child: widget.isResendLoading
                  ? SizedBox(
                      width: 16.w,
                      height: 16.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor,
                        ),
                      ),
                    )
                  : Text(
                      'Resend',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: widget.canResend
                            ? Theme.of(context).primaryColor
                            : Colors.grey[400],
                        fontWeight: FontWeight.w600,
                        decoration: widget.canResend
                            ? TextDecoration.underline
                            : TextDecoration.none,
                      ),
                    ),
            ),
          ],
        ),

        if (!widget.canResend && _currentSeconds <= 10)
          Padding(
            padding: EdgeInsets.only(top: 12.h),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(6.w),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Text(
                'Code expires soon!',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.red[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
