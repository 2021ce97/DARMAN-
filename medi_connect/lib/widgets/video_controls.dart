import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Reusable video call control button widget.
class VideoControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final bool isDanger;
  final VoidCallback onTap;
  final double size;

  const VideoControlButton({
    super.key,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.isDanger = false,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    if (isDanger) {
      bgColor = AppColors.error;
    } else if (isActive) {
      bgColor = Colors.white.withOpacity(0.2);
    } else {
      bgColor = Colors.red.withOpacity(0.3);
    }

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
              boxShadow: isDanger
                  ? [
                      BoxShadow(
                        color: AppColors.error.withOpacity(0.4),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Icon(icon, color: Colors.white, size: size * 0.46),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Full control bar used at the bottom of the video consultation screen.
class VideoControlsBar extends StatelessWidget {
  final bool isMicMuted;
  final bool isCameraOff;
  final bool isSpeakerOn;
  final bool isChatOpen;
  final VoidCallback onToggleMic;
  final VoidCallback onToggleCamera;
  final VoidCallback onToggleSpeaker;
  final VoidCallback onToggleChat;
  final VoidCallback onEndCall;

  const VideoControlsBar({
    super.key,
    required this.isMicMuted,
    required this.isCameraOff,
    required this.isSpeakerOn,
    required this.isChatOpen,
    required this.onToggleMic,
    required this.onToggleCamera,
    required this.onToggleSpeaker,
    required this.onToggleChat,
    required this.onEndCall,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withOpacity(0.8),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          VideoControlButton(
            icon: isMicMuted ? Icons.mic_off : Icons.mic,
            label: isMicMuted ? 'Unmute' : 'Mute',
            isActive: !isMicMuted,
            onTap: onToggleMic,
          ),
          VideoControlButton(
            icon: isCameraOff ? Icons.videocam_off : Icons.videocam,
            label: isCameraOff ? 'Start Video' : 'Stop Video',
            isActive: !isCameraOff,
            onTap: onToggleCamera,
          ),
          VideoControlButton(
            icon: isSpeakerOn ? Icons.volume_up : Icons.volume_off,
            label: isSpeakerOn ? 'Speaker' : 'Earpiece',
            isActive: isSpeakerOn,
            onTap: onToggleSpeaker,
          ),
          VideoControlButton(
            icon: Icons.chat_bubble_outline,
            label: 'Chat',
            isActive: isChatOpen,
            onTap: onToggleChat,
          ),
          VideoControlButton(
            icon: Icons.call_end,
            label: 'End',
            isActive: true,
            isDanger: true,
            onTap: onEndCall,
            size: 64,
          ),
        ],
      ),
    );
  }
}

/// Signal quality indicator widget.
class SignalQualityIndicator extends StatelessWidget {
  final int quality; // 0-3: poor, fair, good, excellent

  const SignalQualityIndicator({super.key, this.quality = 3});

  Color get _color {
    switch (quality) {
      case 0:
        return Colors.red;
      case 1:
        return Colors.orange;
      case 2:
        return Colors.yellow;
      default:
        return Colors.green;
    }
  }

  String get _label {
    switch (quality) {
      case 0:
        return 'Poor';
      case 1:
        return 'Fair';
      case 2:
        return 'Good';
      default:
        return 'Excellent';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.signal_cellular_alt, color: _color, size: 16),
        const SizedBox(width: 4),
        Text(
          _label,
          style: TextStyle(color: _color, fontSize: 12),
        ),
      ],
    );
  }
}
