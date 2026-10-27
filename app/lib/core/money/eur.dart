/// An amount from the server's earnings fields, as a photographer reads it.
///
/// The balance and earnings responses carry no currency field: each amount
/// is named for its currency (`withdrawable_eur`, `pending_eur`), so the
/// currency is the server's, stated in the field it comes from. This is the
/// one place that turns such a field into text - if the server ever sends a
/// currency, it changes here and nowhere else.
/// The symbol, for a label that names the currency ("Amount (€)").
const eurSymbol = '€';

String eur(String amount) => '$eurSymbol$amount';
