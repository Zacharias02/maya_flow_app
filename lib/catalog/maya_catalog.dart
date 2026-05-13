import 'package:genui/genui.dart';

import 'widgets/account_limit_bar.dart';
import 'widgets/duplicate_profile_choice.dart';
import 'widgets/rewards_carousel.dart';
import 'widgets/send_money_to_user_form.dart';
import 'widgets/transaction_card.dart';
import 'widgets/yes_no_prompt.dart';

const mayaCatalogId = 'maya-catalog';

Catalog mayaCatalog() {
  return Catalog(
    [
      transactionCard,
      accountLimitBar,
      rewardsCarousel,
      sendMoneyToUserForm,
      duplicateProfileChoice,
      yesNoPrompt,
    ],
    catalogId: mayaCatalogId,
  );
}
