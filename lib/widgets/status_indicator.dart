import 'package:flutter/material.dart';
import 'package:re_kyc_mobile_app/widgets/custom_text.dart';

enum StatusIndicatorType {
  paused,
  error,
  finished,
  inProgress,
  testing,
}

class StatusIndicator extends StatelessWidget {
  const StatusIndicator({
    super.key,
    required this.label,
    this.type = StatusIndicatorType.testing,
  });

  final String label;
  final StatusIndicatorType type;

  factory StatusIndicator.fromStatus(String status, {Key? key}) {
    return StatusIndicator(
      key: key,
      label: status,
      type: resolveType(status),
    );
  }

  static StatusIndicatorType resolveType(String status) {
    final value = status.trim().toLowerCase();
    if (value.contains('withdraw') ||
        value.contains('error') ||
        value.contains('reject') ||
        value.contains('fail')) {
      return StatusIndicatorType.error;
    }
    if (value.contains('complete') ||
        value.contains('finish') ||
        value.contains('success') ||
        value == 'done') {
      return StatusIndicatorType.finished;
    }
    if (value.contains('in progress') ||
        value.contains('inprogress') ||
        value.contains('processing')) {
      return StatusIndicatorType.inProgress;
    }
    if (value.contains('test')) {
      return StatusIndicatorType.testing;
    }
    if (value.contains('pending') ||
        value.contains('pause') ||
        value.contains('hold')) {
      return StatusIndicatorType.paused;
    }
    return StatusIndicatorType.testing;
  }

  Color get _backgroundColor {
    switch (type) {
      case StatusIndicatorType.paused:
        return const Color(0xFFFFF4D6);
      case StatusIndicatorType.error:
        return const Color(0xFFFDECEC);
      case StatusIndicatorType.finished:
        return const Color(0xFFE7F6EC);
      case StatusIndicatorType.inProgress:
        return const Color(0xFFF1E8FF);
      case StatusIndicatorType.testing:
        return const Color(0xFFE7F1FB);
    }
  }

  Color get _textColor {
    switch (type) {
      case StatusIndicatorType.paused:
        return const Color(0xFF9A6B1F);
      case StatusIndicatorType.error:
        return const Color(0xFFC62828);
      case StatusIndicatorType.finished:
        return const Color(0xFF2E7D32);
      case StatusIndicatorType.inProgress:
        return const Color(0xFF6A1B9A);
      case StatusIndicatorType.testing:
        return const Color(0xFF3D5A80);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: CustomText(
        text: label,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: _textColor,
      ),
    );
  }
}
