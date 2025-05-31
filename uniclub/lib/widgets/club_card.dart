import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/club_model.dart';
import '../models/college_model.dart';

class ClubCard extends StatelessWidget {
  final ClubModel club;
  final CollegeModel? college;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool showCollegeName;

  const ClubCard({
    super.key,
    required this.club,
    this.college,
    this.onTap,
    this.trailing,
    this.showCollegeName = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Club Profile Image
              CircleAvatar(
                radius: 30,
                backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                backgroundImage: club.profileImageUrl != null
                    ? CachedNetworkImageProvider(club.profileImageUrl!)
                    : null,
                child: club.profileImageUrl == null
                    ? Icon(
                        Icons.group,
                        size: 30,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              
              // Club Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      club.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (showCollegeName && college != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        college!.name,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      club.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.people,
                          size: 16,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${club.memberCount} members',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Trailing widget (e.g., join button, menu)
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}