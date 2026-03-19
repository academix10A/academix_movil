import 'package:flutter/material.dart';
import 'package:academix/core/constants/app_spacing.dart';
import 'package:academix/core/themes/app_text_styles.dart';
import 'package:academix/core/themes/app_colors.dart';
import 'package:academix/core/constants/app_radius.dart';
import '../viewmodel/offline_viewmodel.dart';

class OfflineContentScreen extends StatefulWidget {
  const OfflineContentScreen({super.key});

  @override
  State<OfflineContentScreen> createState() => _OfflineContentScreenState();
}

class _OfflineContentScreenState extends State<OfflineContentScreen> {
  final OfflineViewModel vm = OfflineViewModel();

  @override
  void dispose() {
    vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Offline', style: AppTextStyles.h2.copyWith(color: AppColors.text)),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          ValueListenableBuilder(
            valueListenable: vm.offlineItems,
            builder: (context, items, _) {
              final unsynced = items.where((i) => !i.synced).length;
              return unsynced > 0
                ? Badge(
                    label: Text('$unsynced'),
                    child: IconButton(
                      icon: Icon(Icons.sync, color: AppColors.text),
                      onPressed: vm.syncAll,
                    ),
                  )
                : IconButton(
                    icon: Icon(Icons.sync, color: AppColors.textMuted),
                    onPressed: null,
                  );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: vm.offlineItems,
        builder: (context, items, _) {
          if (vm.isSyncing) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_off, size: 80, color: AppColors.textMuted),
                  const SizedBox(height: AppSpacing.md),
                  Text('No hay contenido offline', style: AppTextStyles.h2.copyWith(color: AppColors.textMuted)),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Descarga recursos para usar sin conexión', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted)),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: items.length,
            separatorBuilder: (_,__) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(Icons.download, color: AppColors.secondary),
                ),
                title: Text(item.title, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.size, style: AppTextStyles.caption),
                    Text(
                      '${item.downloadedAt.toLocal().toString().split(' ')[0]}',
                      style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
                trailing: item.synced 
                  ? Icon(Icons.cloud_done, color: AppColors.success, size: 24)
                  : Icon(Icons.cloud_off, color: AppColors.warning, size: 24),
                onTap: () {
                  // Open offline
                },
              );
            },
          );
        },
      ),
    );
  }
}

