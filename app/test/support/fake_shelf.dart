import 'package:rawwers/api/models/shelf_browse_item.dart';
import 'package:rawwers/api/models/shelf_browse_level.dart';
import 'package:rawwers/api/models/shelf_browse_response.dart';

ShelfBrowseItem shelfItem({
  String id = 'i1',
  String title = 'NP-FZ100 battery',
  int level = 1,
  int price = 150,
  bool fits = false,
  bool wished = false,
  bool affordable = true,
  bool inStock = true,
  bool locked = false,
}) =>
    ShelfBrowseItem(
      id: id,
      title: title,
      category: 'battery',
      level: level,
      priceRaww: price,
      inStock: inStock,
      fitsYourGear: fits,
      wished: wished,
      affordable: affordable,
      locked: locked,
    );

ShelfBrowseResponse shelfView({
  bool hasCamera = true,
  int spendable = 300,
  List<ShelfBrowseLevel>? levels,
  bool termsDraft = true,
  int ordersThisMonth = 1,
  DateTime? ordersResetAt,
}) =>
    ShelfBrowseResponse(
      tier: 'rookie',
      maxLevel: 3,
      spendable: spendable,
      hasCamera: hasCamera,
      wishlistMax: 3,
      ordersThisMonth: ordersThisMonth,
      maxOrdersPerMonth: 3,
      ordersResetAt: ordersResetAt ?? DateTime.utc(2026, 12, 1),
      termsText: 'DRAFT - not reviewed. RAWW have no cash value.',
      termsDraft: termsDraft,
      levels: levels ??
          [
            ShelfBrowseLevel(level: 1, bandRaww: 100, locked: false, items: [shelfItem(fits: true), shelfItem(id: 'i2', title: 'Card')]),
            ShelfBrowseLevel(
              level: 4,
              bandRaww: 3000,
              locked: true,
              unlocksAtTier: 'skilled',
              items: [shelfItem(id: 'i4', title: 'Gimbal', level: 4, price: 3200, locked: true)],
            ),
          ],
    );
