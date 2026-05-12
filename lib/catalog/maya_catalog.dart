import 'package:genui/genui.dart';

import 'widgets/account_limit_bar.dart';
import 'widgets/transaction_card.dart';
import 'widgets/update_details_form.dart';

const mayaCatalogId = 'maya-catalog';

Catalog mayaCatalog() {
  return Catalog(
    [transactionCard, accountLimitBar, updateDetailsForm],
    catalogId: mayaCatalogId,
  );
}
