/// Placeholder support address for the MVP's manual deletion process.
/// Replace once a real support inbox exists.
const deletionRequestEmail = 'privacy@laternote.app';

/// A mailto link asking support to delete the account for [accountEmail].
Uri deletionRequestUri(String? accountEmail) => Uri(
  scheme: 'mailto',
  path: deletionRequestEmail,
  query:
      'subject=${Uri.encodeComponent('Account deletion request')}'
      '&body=${Uri.encodeComponent(
        'Please delete the Laternote account for: ${accountEmail ?? ''}',
      )}',
);
