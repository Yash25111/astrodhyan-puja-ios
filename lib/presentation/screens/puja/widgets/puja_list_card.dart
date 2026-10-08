import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../app_colors.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../data/models/puja.dart';
import '../../../../widgets/app_card.dart';
import '../../../../widgets/app_rupee_amount.dart';

class PujaListCard extends StatelessWidget {
  static const imageAspectRatio = 1241 / 620;

  final Puja puja;
  final VoidCallback onTap;

  const PujaListCard({super.key, required this.puja, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              child: AspectRatio(
                aspectRatio: imageAspectRatio,
                child: CachedNetworkImage(
                  imageUrl: ApiEndpoints.image(puja.pujaImage),
                  fit: BoxFit.cover,
                  errorWidget: (_, _, _) => const ColoredBox(
                    color: AppColors.cream,
                    child: Icon(
                      Icons.temple_hindu,
                      color: AppColors.primary,
                      size: 42,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(13),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [


                  ///isPopular
                  // if (puja.isPopular || puja.isFeatured)
                  //   Text(
                  //     puja.isFeatured ? 'FEATURED' : 'POPULAR',
                  //     style: const TextStyle(
                  //       color: AppColors.primary,
                  //       fontSize: 9,
                  //       fontWeight: FontWeight.w800,
                  //     ),
                  //   ),
                  //

                  const SizedBox(height: 5),
                  Text(
                    puja.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  // const SizedBox(height: 5),
                  // Text(
                  //   puja.shortDescription,
                  //   maxLines: 2,
                  //   overflow: TextOverflow.ellipsis,
                  //   style: const TextStyle(
                  //     fontSize: 12,
                  //     color: AppColors.subheading,
                  //     height: 1.3,
                  //   ),
                  // ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: AppColors.grey,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          puja.location.isEmpty ? 'Online Puja' : puja.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.grey,
                          ),
                        ),
                      ),
                      AppRupeeAmount(
                        amount: puja.actualPrice,
                        fontSize: 15,
                        color: AppColors.primaryDark,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
