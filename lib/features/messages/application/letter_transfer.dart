import 'dart:async';
import 'dart:ui';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/clock.dart';
import '../../notifications/application/ready_notifications.dart';
import '../data/letter_file_repository.dart';
import '../data/letters_file.dart';
import '../data/messages_repository.dart';
import 'inbox.dart';
import 'upcoming_messages.dart';

part 'letter_transfer.g.dart';

/// Where an export goes.
enum ExportTarget {
  /// The system save dialog, to a folder the user picks.
  save,

  /// The share sheet, to another app.
  share,
}

/// What the last export or import did, for the UI to report.
sealed class TransferOutcome {
  const TransferOutcome();
}

/// The export file was saved.
final class ExportSaved extends TransferOutcome {
  const ExportSaved();
}

/// An import added [added] letters (0 when it had none new).
final class LettersImported extends TransferOutcome {
  const LettersImported(this.added);

  final int added;
}

/// Exports letters to a file and imports them back. Holds the outcome of the
/// last run, or null when there is nothing to report (shared, or cancelled).
@riverpod
class LetterTransfer extends _$LetterTransfer {
  @override
  FutureOr<TransferOutcome?> build() => null;

  /// Writes every letter to a file and saves or shares it. [origin] anchors
  /// the share sheet on iPad.
  Future<void> export(ExportTarget target, {Rect? origin}) => _run(() async {
    final now = ref.read(clockProvider)();
    final letters = await ref.read(messagesRepositoryProvider).exportAll();
    final bytes = encodeLetters(letters, now);
    final files = ref.read(letterFileRepositoryProvider);
    switch (target) {
      case ExportTarget.save:
        return await files.save(bytes, _fileName(now))
            ? const ExportSaved()
            : null;
      case ExportTarget.share:
        await files.share(bytes, _fileName(now), origin);
        return null;
    }
  });

  /// Adds the letters of a picked file that aren't on the device yet and
  /// schedules their notifications. An invalid file adds nothing.
  Future<void> import() => _run(() async {
    final bytes = await ref.read(letterFileRepositoryProvider).pick();
    if (bytes == null) return null;
    final letters = decodeLetters(bytes);
    final added = await ref
        .read(messagesRepositoryProvider)
        .importLetters(letters);
    if (added > 0 && ref.mounted) {
      ref
        ..invalidate(upcomingMessagesProvider)
        ..invalidate(availableMessagesProvider);
      unawaited(ref.read(readyNotificationsProvider.notifier).sync());
    }
    return LettersImported(added);
  });

  Future<void> _run(Future<TransferOutcome?> Function() action) async {
    if (state.isLoading) return;
    state = const AsyncLoading();
    final result = await AsyncValue.guard(action);
    if (ref.mounted) state = result;
  }

  static String _fileName(DateTime now) {
    String two(int n) => n.toString().padLeft(2, '0');
    return 'laternote-${now.year}-${two(now.month)}-${two(now.day)}.json';
  }
}
