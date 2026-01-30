import 'package:flutter/material.dart';
import 'package:seerah_timeline/components/ui/save_button.dart';

class AvatarPositioned extends StatelessWidget {
  final String? imageUrl;
  final VoidCallback? onTap;

  const AvatarPositioned({super.key, this.imageUrl, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 140,
      left: 0,
      right: 0,
      child: GestureDetector(
        onTap: onTap,
        child: CircleAvatar(
          radius: 64,
          backgroundColor: Colors.white,
          child: CircleAvatar(
            radius: 58,
            backgroundColor: Colors.grey.shade300,
            backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
            child: imageUrl == null
                ? const Icon(Icons.person, size: 56, color: Colors.white)
                : null,
          ),
        ),
      ),
    );
  }
}

// Widget that provides upload button for avatar
class AvatarUploadButton extends StatelessWidget {
  final VoidCallback? onUpload;

  const AvatarUploadButton({super.key, this.onUpload});

  @override
  Widget build(BuildContext context) {
    return SaveButton(
      onPressed: onUpload,
      label: 'Upload Image',
      icon: Icons.camera_alt,
      backgroundColor: Colors.blue,
      isCompact: true,
    );
  }
}
