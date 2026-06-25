const mockClientFirstName = 'Gab';

// Predefined demo tickets — number maps to concern title.
const _kMockTickets = <String, String>{
  '20613427': 'Instapay Transfer Not Credited',
  '09121994': 'Account Deactivation Request',
};

/// Returns the predefined ticket number for a given [prefillTitle], or an
/// empty string if no match (caller should fall back to a random number).
String mockTicketNumberFor(String prefillTitle) {
  final lower = prefillTitle.toLowerCase();
  if (lower.contains('instapay')) return '20613427';
  if (lower.contains('deactivat')) return '09121994';
  return '';
}

/// Returns the concern title for [ticketNumber], or null if not found.
String? mockConcernForTicket(String ticketNumber) => _kMockTickets[ticketNumber.trim()];

/// Returns category tags for a given concern title.
List<String> categoriesForConcern(String concern) {
  final lower = concern.toLowerCase();
  if (lower.contains('instapay') || lower.contains('transfer')) {
    return ['InstaPay', 'Transfers'];
  }
  if (lower.contains('deactivat')) {
    return ['Account', 'Deactivation'];
  }
  return ['Support'];
}

const mockUserContext = '''
User: Gab Garrero
Email: gab@example.com
Registered Mobile: +63 917 123 4567
Maya Handle: @gab_garrero

Pending Instapay Transaction:
  Reference No: IPN-20260622-00847
  Amount: PHP 3,500.00
  Sender: Juan dela Cruz (BDO Unibank)
  Status: Pending
  Date: June 22, 2026 at 10:14 AM
  Expected Settlement: June 22, 2026

Account:
  Status: Active
  Total Limit: PHP 50,000.00
  Used: PHP 12,000.00
  Available: PHP 38,000.00
''';
