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
    ref.onDispose(_flush);
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

  /// Deletes the draft from the device, after sealing or on discard.
  Future<void> clear() async {
    _pendingSave?.cancel();
    _set(const MessageDraft());
    await _repository.clear();
  }

  void _set(MessageDraft draft) => state = AsyncData(_latest = draft);

  void _flush() {
    if (_pendingSave?.isActive ?? false) {
      _pendingSave!.cancel();
      _save();
    }
  }

  void _save() {
    // Best effort: a failed autosave leaves the in-memory draft editable and
    // sealable, and the next edit retries.
    _repository.save((
      body: _latest.body,
      deliverAt: _latest.deliverAt,
    )).ignore();
  }
}

/// Seals the draft: syncs it to Supabase as `scheduled`, then deletes the
/// local draft. Holds the delivery time once sealed.
@riverpod
class SealMessageController extends _$SealMessageController {
  @override
  FutureOr<DateTime?> build() => null;

  Future<void> seal(MessageDraft draft) async {
    state = const AsyncLoading();
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
      ref.invalidate(upcomingMessagesProvider);
      await ref.read(composeDraftProvider.notifier).clear();
      return draft.deliverAt;
    });
    if (ref.mounted) state = result;
  }
}
