import 'dart:async';

import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/app_error.dart';
import '../../../core/clock.dart';
import '../data/draft_repository.dart';
import '../data/messages_repository.dart';
import 'message_draft.dart';
import 'upcoming_messages.dart';

part 'compose_controllers.g.dart';

/// The device's IANA time zone (e.g. `Europe/Rome`). Local [DateTime]s are
/// in this zone, so `toUtc()` gives the matching instant.
@Riverpod(keepAlive: true)
Future<String> deviceTimezone(Ref ref) async =>
    (await FlutterTimezone.getLocalTimezone()).identifier;

/// How long body edits settle before the draft is saved.
const draftSaveDelay = Duration(milliseconds: 300);

/// Whether the last attempt to save the draft on the device failed. Cleared
/// by the next successful save.
@riverpod
class DraftSaveFailed extends _$DraftSaveFailed {
  @override
  bool build() => false;

  void set(bool failed) => state = failed;
}

/// The unsealed message being composed, shared by the compose and review
/// screens. Restored from and autosaved to the device; never synced.
@riverpod
class ComposeDraft extends _$ComposeDraft {
  late DraftRepository _repository;
  MessageDraft _latest = const MessageDraft();
  Timer? _pendingSave;

  @override
  Future<MessageDraft> build() async {
    _repository = ref.read(draftRepositoryProvider);
    // Keeps the save status alive for as long as the draft is.
    ref.listen(draftSaveFailedProvider, (_, _) {});
    ref.onDispose(flush);
    final stored = await _repository.load();
    return _latest = stored == null
        ? const MessageDraft()
        : MessageDraft(body: stored.body, deliverAt: stored.deliverAt);
  }

  void setBody(String body) {
    _set(_latest.copyWith(body: body));
    _pendingSave?.cancel();
    _pendingSave = Timer(draftSaveDelay, _save);
  }

  void setDeliverAt(DateTime deliverAt) {
    _set(_latest.copyWith(deliverAt: deliverAt));
    _pendingSave?.cancel();
    _save();
  }

  /// Saves an edit that is still waiting for [draftSaveDelay], e.g. when the
  /// app goes to the background and may be killed.
  void flush() {
    if (_pendingSave?.isActive ?? false) {
      _pendingSave!.cancel();
      _save();
    }
  }

  /// Deletes the draft from the device, after sealing or on discard.
  Future<void> clear() async {
    _pendingSave?.cancel();
    _set(const MessageDraft());
    await _repository.clear();
  }

  void _set(MessageDraft draft) => state = AsyncData(_latest = draft);

  Future<void> _save() async {
    // A failed save leaves the in-memory draft editable and sealable; the
    // screen says it isn't saved and the next edit retries.
    bool failed;
    try {
      await _repository.save((
        body: _latest.body,
        deliverAt: _latest.deliverAt,
      ));
      failed = false;
    } on Object {
      failed = true;
    }
    if (ref.mounted) ref.read(draftSaveFailedProvider.notifier).set(failed);
  }
}

/// Seals the draft: syncs it to Supabase as `scheduled`, then deletes the
/// local draft. Holds the delivery time once sealed.
@riverpod
class SealMessageController extends _$SealMessageController {
  @override
  FutureOr<DateTime?> build() => null;

  Future<void> seal(MessageDraft draft) async {
    // Sealed already or in progress: sealing again would duplicate it.
    if (state.isLoading || state.value != null) return;
    state = const AsyncLoading();
    // Read before any await, so the draft is cleared even if the user leaves
    // the review screen while sealing.
    final localDraft = ref.read(composeDraftProvider.notifier);
    final result = await AsyncValue.guard(() async {
      // Re-check: time may have passed while the user was reviewing.
      final invalid =
          validateBody(draft.body) ??
          validateDeliverAt(draft.deliverAt, ref.read(clockProvider)());
      if (invalid != null) throw ValidationError(invalid);

      await ref
          .read(messagesRepositoryProvider)
          .createScheduledMessage(
            body: draft.body,
            scheduledFor: draft.deliverAt!,
            timezone: await ref.read(deviceTimezoneProvider.future),
          );
      return draft.deliverAt;
    });
    if (result.hasValue) {
      if (ref.mounted) ref.invalidate(upcomingMessagesProvider);
      // The message is sealed whatever happens here, so a failure must not
      // be reported as a failed seal (the user would seal it twice).
      try {
        await localDraft.clear();
      } on Object {
        // The draft stays on the device; the user can discard it.
      }
    }
    if (ref.mounted) state = result;
  }
}
