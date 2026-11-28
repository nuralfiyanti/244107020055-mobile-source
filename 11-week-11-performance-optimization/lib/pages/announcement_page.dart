import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class AnnouncementPage extends StatelessWidget {
  const AnnouncementPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    final bannerUrl = 'https://picsum.photos/seed/campus-$id/600/300';

    return Scaffold(
      appBar: AppBar(title: Text('Pengumuman $id')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: bannerUrl,
                height: 180,
                fit: BoxFit.cover,
                memCacheWidth: 600,
                memCacheHeight: 300,
                fadeInDuration: const Duration(milliseconds: 200),
                placeholder: (_, _) => const SizedBox(
                  height: 180,
                  child: Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (_, _, _) => const SizedBox(
                  height: 180,
                  child: Center(child: Icon(Icons.campaign, size: 48)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Isi pengumuman dengan id: $id',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
