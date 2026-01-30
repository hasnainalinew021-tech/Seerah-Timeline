import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:seerah_timeline/auth/auth_service.dart';
import 'package:seerah_timeline/components/ui/avatar.dart';
import 'package:seerah_timeline/constants/app_colors.dart';
import 'package:seerah_timeline/main.dart';
import 'package:seerah_timeline/screen/login_screen.dart';
import 'package:seerah_timeline/widget/profile_input_field.dart';
import 'package:seerah_timeline/components/ui/signout_button.dart';
import 'package:seerah_timeline/components/ui/save_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _getInitialProfile();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _getInitialProfile() async {
    final userId = supabase.auth.currentUser!.id;
    final data = await supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();
    setState(() {
      _usernameController.text = data['username'];
      _emailController.text = data['email'];
      _imageUrl = data['avatar_url'];
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header area
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1FAAA3), // teal-ish
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              'Seerah Journey',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Journey Through the Seerah',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.nights_stay,
                        color: Color(0xFFF59E0B),
                        size: 32,
                      ),
                    ],
                  ),
                ),

                // avatar overlapping (extracted to widget)
                AvatarPositioned(
                  imageUrl: _imageUrl,
                  onTap: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (image == null) {
                      return;
                    }
                    final imageBytes = await image.readAsBytes();
                    final userId = supabase.auth.currentUser!.id;
                    final imagePath = '/$userId/profile';
                    await supabase.storage
                        .from('profiles')
                        .uploadBinary(imagePath, imageBytes);
                    final imageUrl = supabase.storage
                        .from('profiles')
                        .getPublicUrl(imagePath);
                    setState(() {
                      _imageUrl = imageUrl;
                    });
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Avatar uploaded successfully!'),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 72),
            AvatarUploadButton(
              onUpload: () async {
                final ImagePicker picker = ImagePicker();
                final XFile? image = await picker.pickImage(
                  source: ImageSource.gallery,
                );
                if (image == null) {
                  return;
                }
                final imageExtension = image.path.split('.').last;
                final imageBytes = await image.readAsBytes();
                final userId = supabase.auth.currentUser!.id;
                final imagePath = '/$userId/profile';
                await supabase.storage
                    .from('profiles')
                    .uploadBinary(
                      imagePath,
                      imageBytes,
                      fileOptions: FileOptions(
                        upsert: true,
                        contentType: 'image/$imageExtension',
                      ),
                    );
                String imageUrl = supabase.storage
                    .from('profiles')
                    .getPublicUrl(imagePath);
                imageUrl = Uri.parse(imageUrl)
                    .replace(
                      queryParameters: {
                        't': DateTime.now().millisecondsSinceEpoch.toString(),
                      },
                    )
                    .toString();
                setState(() {
                  _imageUrl = imageUrl;
                });
                await supabase
                    .from('profiles')
                    .update({'avatar_url': imageUrl})
                    .eq('id', userId);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Avatar uploaded successfully!'),
                    ),
                  );
                }
              },
            ),

            const SizedBox(height: 10),

            // Name below avatar
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _usernameController,
              builder: (_, value, __) => Text(
                value.text.isEmpty ? 'Your name' : value.text,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _emailController,
              builder: (_, value, __) => Text(
                value.text.isEmpty ? 'Your email' : value.text,
                style: TextStyle(color: Colors.black54),
              ),
            ),
            const SizedBox(height: 20),

            // Actions -> replaced with profile input fields and sign out
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    'If you want to edit your name or email then update them here...',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Profile input rows
                  ProfileInputField(
                    controller: _usernameController,
                    hintText: 'Username',
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 12),
                  ProfileInputField(
                    controller: _emailController,
                    hintText: 'Email',
                    icon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 12),

                  // spacing before Save
                  const SizedBox(height: 10),

                  // Small circular Save button centered
                  SaveButton(
                    onPressed: () async {
                      final username = _usernameController.text.trim();
                      final email = _emailController.text.trim();
                      final userId = supabase.auth.currentUser!.id;
                      await supabase
                          .from('profiles')
                          .update({'username': username, 'email': email})
                          .eq('id', userId);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Profile updated successfully!'),
                          ),
                        );
                      }
                      _getInitialProfile();
                    },
                  ),

                  // spacing after Save
                  const SizedBox(height: 25),

                  // Keep sign out action
                  ProfileAction(
                    icon: Icons.logout,
                    label: 'Sign out',
                    showArrow: false,
                    centerContent: true,
                    onTap: () async {
                      await auth.signOut();
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                          (route) => false,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
