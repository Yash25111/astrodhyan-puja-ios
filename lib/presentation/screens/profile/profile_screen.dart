import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app_colors.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../widgets/app_card.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/profile/profile_bloc.dart';
import '../../router/app_router.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(const ProfileRequested());
  }

  @override
  Widget build(BuildContext c) {
    return SafeArea(
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (c, s) {
          final p = s.profile;
          return ListView(
            padding: const EdgeInsets.all(18),
            children: [
              AppCard(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 34,
                      backgroundColor: AppColors.cream,
                      backgroundImage: p?.image.isNotEmpty == true
                          ? CachedNetworkImageProvider(
                              ApiEndpoints.image(p!.image),
                            )
                          : null,
                      child: p?.image.isNotEmpty == true
                          ? null
                          : const Icon(
                              Icons.person,
                              size: 34,
                              color: AppColors.primary,
                            ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p?.name.isNotEmpty == true ? p!.name : 'Devotee',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (p?.number.isNotEmpty == true) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(
                                  Icons.phone_outlined,
                                  size: 15,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    p!.number,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.subheading,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (p?.email.isNotEmpty == true)
                            Text(
                              p!.email,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.grey,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () =>
                      Navigator.pushNamed(c, AppRouter.profileEdit),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit Profile'),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Account',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _item(
                      Icons.event_note_outlined,
                      'My Bookings',
                      () => Navigator.pushNamed(c, AppRouter.bookings),
                    ),
                    const Divider(height: 1),
                    _item(
                      Icons.notifications_none,
                      'Notifications',
                      () => Navigator.pushNamed(c, AppRouter.notifications),
                    ),
                    const Divider(height: 1),
                    _item(
                      Icons.help_outline,
                      'Help & Support',
                      () => Navigator.pushNamed(c, AppRouter.support),
                    ),
                    const Divider(height: 1),
                    _item(
                      Icons.privacy_tip_outlined,
                      'Terms & Privacy',
                      () => Navigator.pushNamed(c, AppRouter.termsPrivacy),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              OutlinedButton(
                onPressed: () {
                  context.read<AuthBloc>().add(const LogoutRequested());
                  Navigator.pushNamedAndRemoveUntil(
                    c,
                    AppRouter.login,
                    (_) => false,
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text(
                  'Logout',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              if (s.loading)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        },
      ),
    );
  }
}

Widget _item(IconData icon, String title, VoidCallback onTap) {
  return ListTile(
    onTap: onTap,
    leading: Icon(icon, color: AppColors.primary),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
    trailing: const Icon(Icons.chevron_right, color: AppColors.grey),
  );
}
