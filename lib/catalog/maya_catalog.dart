import 'package:genui/genui.dart';

import 'widgets/qualifications_card.dart';
import 'widgets/ticket_card.dart';
import 'widgets/ticket_lookup_card.dart';

const mayaCatalogId = 'maya-catalog';

Catalog mayaCatalog() {
  return Catalog(
    [qualificationsCard, ticketCard, ticketLookupCard],
    catalogId: mayaCatalogId,
  );
}
