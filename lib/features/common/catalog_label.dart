import '../../data/repositories/catalog_repository.dart';
import '../../l10n/app_localizations.dart';

/// Display name of a catalog item: the translation of its seeded `code`, or
/// its stored name for rows the user added (or codes with no translation).
String catalogLabel(AppLocalizations l, CatalogItem item) {
  final translated = switch (item.code) {
    'cash' => l.catalog_cash,
    'card' => l.catalog_card,
    'bizum' => l.catalog_bizum,
    'vouchers' => l.catalog_vouchers,
    'glovo' => l.catalog_glovo,
    'justeat' => l.catalog_justeat,
    'ubereats' => l.catalog_ubereats,
    'meat' => l.catalog_meat,
    'fish' => l.catalog_fish,
    'vegetables' => l.catalog_vegetables,
    'drinks' => l.catalog_drinks,
    'groceries' => l.catalog_groceries,
    'cleaning' => l.catalog_cleaning,
    'utilities' => l.catalog_utilities,
    'rent' => l.catalog_rent,
    'insurance' => l.catalog_insurance,
    'selfemployed' => l.catalog_selfemployed,
    'advisor' => l.catalog_advisor,
    'other' => l.catalog_other,
    'bank_deposit' => l.catalog_bank_deposit,
    'owner' => l.catalog_owner,
    'cash_payment' => l.catalog_cash_payment,
    'change' => l.catalog_change,
    _ => null,
  };
  return translated ?? item.name;
}
