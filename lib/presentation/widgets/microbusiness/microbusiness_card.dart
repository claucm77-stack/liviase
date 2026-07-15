import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/microbusiness.dart';

class MicrobusinessCard extends StatelessWidget {
  const MicrobusinessCard({
    super.key,
    required this.business,
    required this.onTap,
    required this.onViewMap,
    required this.onHowToGet,
    required this.onToggleFavorite,
    required this.isFavorite,
  });

  final Microbusiness business;
  final VoidCallback onTap;
  final VoidCallback onViewMap;
  final VoidCallback onHowToGet;
  final VoidCallback onToggleFavorite;
  final bool isFavorite;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BusinessImage(imageUrl: business.imagen),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      business.nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        business.categoria,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      business.descripcion,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton.icon(
                          onPressed: onViewMap,
                          icon: const Icon(Icons.map_outlined),
                          label: const Text('Mapa'),
                        ),
                        OutlinedButton.icon(
                          onPressed: onHowToGet,
                          icon: const Icon(Icons.directions_outlined),
                          label: const Text('Llegar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onToggleFavorite,
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BusinessImage extends StatelessWidget {
  const _BusinessImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 76,
        height: 76,
        child: imageUrl.isEmpty
            ? Container(
                color: AppColors.surfaceAlt,
                child: const Icon(Icons.storefront, color: AppColors.primary),
              )
            : Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.broken_image_outlined),
                ),
              ),
      ),
    );
  }
}
