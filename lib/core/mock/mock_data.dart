const mockClientFirstName = 'Gab';

const mockUserContext = '''
User: Gabriel (Gab) Garrero
Email: gabgarrero@gmail.com
Phone: +63 917 123 4567

Recent Transaction:
  Merchant: SM Supermarket
  Amount: PHP 5,000.00
  Status: Declined
  Reason: Insufficient funds
  Date: May 10, 2026

Account Limit:
  Total: PHP 50,000.00
  Used: PHP 38,500.00
  Available: PHP 11,500.00

== DUPLICATE PROFILES (DuplicateProfileChoice — pick one to keep) ==
**Assistant note:** In this demo, after the user confirms keep/remove, narrate **processing** then **removal always fails**, then open a **support ticket** in plain text (no ticket widget). Only these two profiles exist—do not invent a third.

**Why this looks like a duplicate (for your Part 1 copy):** same legal name on both records, **same mobile number** on file, sign-ups **two days apart**, emails that differ by a dot (`gabgarrero` vs `gab.garrero`), and Maya handles that are one letter apart (`@gabgarrero` vs `@gabgarero`). Same masked card appears on both — typical automated duplicate-account flag.

Profile **Alpha** (internal id: MCH-DUP-ALPHA-01)
  Label: Alpha (first signup — completed KYC)
  Legal name: Gabriel (Gab) Garrero
  Email: gabgarrero@gmail.com
  Phone: +63 917 123 4567
  Maya handle: @gabgarrero
  Opened: Jan 14, 2026
  Card on file: •••• 4421
  Device / region: Metro Manila · same handset ID as Beta

Profile **Beta** (internal id: MCH-DUP-BETA-02)
  Label: Beta (retry signup — partial KYC)
  Legal name: Gabriel Garrero
  Email: gab.garrero@gmail.com
  Phone: +63 917 123 4567
  Maya handle: @gabgarero
  Opened: Jan 16, 2026
  Card on file: •••• 4421
  Device / region: Metro Manila · same handset ID as Alpha

If the user is unsure, suggest keeping **Alpha** (full handle @gabgarrero, completed KYC, matches the app email on this thread) but still require an explicit choice on DuplicateProfileChoice.
''';
