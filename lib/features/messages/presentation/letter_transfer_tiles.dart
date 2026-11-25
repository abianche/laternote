import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/error_message.dart';
import '../../../l10n/app_localizations.dart';
import '../application/letter_transfer.dart';

/// Settings rows to export letters to a file and import them back.
class LetterTransferTiles extends ConsumerWidget {
  const LetterTransferTiles({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final busy = ref.watch(letterTransferProvider).isLoading;
    ref.listen(letterTransferProvider, (previous, next) {
      if (!(previous?.isLoading ?? false) || next.isLoading) return;
      final text = switch (next) {
        AsyncData(value: final added?) => l10n.importAdded(added),
        AsyncData() => null,
        _ => errorMessage(context, next),
      };
      if (text == null) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(text)));
    });

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Builder(
          // Own context so the iPad share sheet points at this row.
          builder: (tileContext) => ListTile(
            leading: const Icon(Icons.upload_file_outlined),
            title: Text(l10n.settingsExport),
            subtitle: Text(l10n.settingsExportSubtitle),
            enabled: !busy,
            onTap: () => _export(tileContext, ref),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.download_outlined),
          title: Text(l10n.settingsImport),
          subtitle: Text(l10n.settingsImportSubtitle),
          enabled: !busy,
          onTap: () => ref.read(letterTransferProvider.notifier).import(),
        ),
      ],
    );
  }

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    final transfer = ref.read(letterTransferProvider.notifier);
    final l10n = AppLocalizations.of(context);
    final box = context.findRenderObject() as RenderBox?;
    final origin = box == null
        ? null
        : box.localToGlobal(Offset.zero) & box.size;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.exportWarningTitle),
        content: Text(l10n.exportWarningBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.exportWarningConfirm),
          ),
        ],
      ),
    );
    if (confirmed ?? false) await transfer.export(origin: origin);
  }
}
