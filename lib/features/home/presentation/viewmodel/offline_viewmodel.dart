import 'package:flutter/material.dart';

class OfflineItem {
  final String id;
  final String type;
  final String title;
  final String size;
  final DateTime downloadedAt;
  final bool synced;

  OfflineItem({
    required this.id,
    required this.type,
    required this.title,
    required this.size,
    required this.downloadedAt,
    this.synced = false,
  });
}

class OfflineViewModel {
  final offlineItems = ValueNotifier<List<OfflineItem>>(OfflineViewModel._getMockOffline());
  bool isSyncing = false;

  void syncAll() async {
    isSyncing = true;
    await Future.delayed(const Duration(seconds: 2));
    // TODO: API sync
    final items = offlineItems.value.map((item) => OfflineItem(
      id: item.id,
      type: item.type,
      title: item.title,
      size: item.size,
      downloadedAt: item.downloadedAt,
      synced: true,
    )).toList();
    offlineItems.value = items;
    isSyncing = false;
  }

  static List<OfflineItem> _getMockOffline() {
    return [
      OfflineItem(
        id: 'o1',
        type: 'resource',
        title: 'Introducción a Álgebra (PDF)',
        size: '2.3 MB',
        downloadedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      OfflineItem(
        id: 'o2',
        type: 'note',
        title: 'Mis notas Historia',
        size: '45 KB',
        downloadedAt: DateTime.now().subtract(const Duration(days: 1)),
        synced: true,
      ),
      OfflineItem(
        id: 'o3',
        type: 'exam',
        title: 'Examen Biología offline',
        size: '120 KB',
        downloadedAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
    ];
  }

  void dispose() {
    offlineItems.dispose();
  }
}

