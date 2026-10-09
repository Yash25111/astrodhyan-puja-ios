import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../app_colors.dart';
import '../../../utils/validators.dart';
import '../../../widgets/app_appbar.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/app_text_field.dart';
import '../../bloc/profile/profile_bloc.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});
  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  String gender = 'Male';
  String? imagePath;
  bool initialized = false;
  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileBloc>().state.profile;
    if (profile != null) _fill(profile);
  }

  void _fill(dynamic profile) {
    if (initialized) return;
    initialized = true;
    nameController.text = profile.name;
    gender = profile.gender.isEmpty ? 'Male' : profile.gender;
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1200,
    );
    if (picked != null && mounted) {
      setState(() => imagePath = picked.path);
    }
  }

  void _submit() {
    if (!formKey.currentState!.validate()) return;
    context.read<ProfileBloc>().add(
      ProfileUpdateRequested(
        name: nameController.text.trim(),
        gender: gender,
        imagePath: imagePath,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(titleText: 'Edit Profile'),
      body: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error!)));
          }
          if (state.updateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile updated successfully')),
            );
            Navigator.pop(context);
          }
        },
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state.profile != null) _fill(state.profile!);
            return Form(
              key: formKey,
              child: ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 48,
                        backgroundColor: AppColors.cream,
                        backgroundImage: imagePath != null
                            ? FileImage(File(imagePath!))
                            : null,
                        child: imagePath == null
                            ? const Icon(
                                Icons.camera_alt_outlined,
                                size: 30,
                                color: AppColors.primary,
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'Tap to change profile photo',
                      style: TextStyle(color: AppColors.grey, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 24),
                  AppCard(
                    child: Column(
                      children: [
                        AppTextField(
                          controller: nameController,
                          labelText: 'Full Name',
                          validator: (value) =>
                              Validators.required(value, 'Name'),
                        ),
                        const SizedBox(height: 14),
                        DropdownButtonFormField<String>(
                          initialValue: gender,
                          decoration: const InputDecoration(
                            labelText: 'Gender',
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Male',
                              child: Text('Male'),
                            ),
                            DropdownMenuItem(
                              value: 'Female',
                              child: Text('Female'),
                            ),
                            DropdownMenuItem(
                              value: 'Other',
                              child: Text('Other'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) setState(() => gender = value);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  AppButton(
                    text: 'Save Changes',
                    loading: state.updating,
                    width: double.infinity,
                    onPressed: _submit,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
