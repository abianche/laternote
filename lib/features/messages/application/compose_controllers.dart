import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/app_error.dart';
import '../../../core/clock.dart';
import '../data/messages_repository.dart';
import 'message_draft.dart';

part 'compose_controllers.g.dart';

/// The device's IANA time zone (e.g. `Europe/Rome`). Local [DateTime]s are
/// in this zone, so `toUtc()` gives the matching instant.
@Riverpod(keepAlive: true)
Future<String> deviceTimezone(Ref ref) async =>
    (await FlutterTimezone.getLocalTimezone()).identifier;

/// The message being composed, shared by the compose and review screens.
@riverpod
class ComposeDraft extends _$ComposeDraft {
  @override
  MessageDraft build() => const MessageDraft();

  void setBody(String body) => state = state.copyWith(body: body);

  void setDeliverAt(DateTime deliverAt) =>
      state = state.copyWith(deliverAt: deliverAt);
}

/// Saves the draft. Holds true once sealed.
@riverpod
class SealMessageController extends _$SealMessageController {
  @override
  FutureOr<bool> build() => false;

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
      return true;
    });
    if (ref.mounted) state = result;
  }
}
