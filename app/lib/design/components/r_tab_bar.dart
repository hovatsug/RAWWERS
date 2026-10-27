import 'package:flutter/material.dart';
import 'package:rawwers/design/tokens.dart';

/// One tab: its words and its two icons. [iconBuilder], when given, draws the
/// icon instead - for a tab that carries a badge.
class RTabItem {
  const RTabItem({required this.label, required this.icon, required this.selectedIcon, this.iconBuilder});

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final Widget Function(BuildContext context, bool selected)? iconBuilder;
}

/// The pro app's bottom tabs in Contact sheet: white, a hairline on top,
/// 12px labels, and the selected tab marked by weight and a short meter700
/// underline - never a filled pill behind the icon. Each tab is a 44px
/// target that tells a screen reader its name and whether it is selected.
class RTabBar extends StatelessWidget {
  const RTabBar({required this.items, required this.selectedIndex, required this.onSelected, super.key});

  final List<RTabItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const groundKey = ValueKey('r-tab-bar-ground');
  static const indicatorKey = ValueKey('r-tab-bar-indicator');

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      key: groundKey,
      decoration: const BoxDecoration(color: RPaper.card, border: Border(top: BorderSide(color: RInk.i200))),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            for (var i = 0; i < items.length; i++)
              Expanded(child: _Tab(item: items[i], selected: i == selectedIndex, onTap: () => onSelected(i))),
          ],
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({required this.item, required this.selected, required this.onTap});

  final RTabItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colour = selected ? RAccent.meter700 : RInk.i600;
    return Semantics(
      container: true,
      selected: selected,
      button: true,
      label: item.label,
      focusable: true,
      onTap: onTap,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: rMinTouchTarget + RSpace.s12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: RSpace.s8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconTheme(
                  data: IconThemeData(color: colour),
                  child: item.iconBuilder?.call(context, selected) ?? Icon(selected ? item.selectedIcon : item.icon),
                ),
                const SizedBox(height: RSpace.s4),
                // Half the gap each side, so two labels are never closer than
                // RMotif.tabLabelGap; capped in size, and shrunk rather than
                // cut if a long word still does not fit.
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: RMotif.tabLabelGap / 2),
                  child: MediaQuery.withClampedTextScaling(
                    maxScaleFactor: RType.tabMaxTextScale,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        item.label,
                        maxLines: 1,
                        style: TextStyle(
                          fontFamily: RType.fontFamily,
                          fontSize: RType.tab,
                          fontVariations: [selected ? RType.weightSemibold : RType.weightRegular],
                          color: selected ? RInk.i950 : RInk.i600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: RSpace.s4),
                SizedBox(
                  height: RMotif.tabIndicatorHeight,
                  child: selected
                      ? const DecoratedBox(
                          key: RTabBar.indicatorKey,
                          decoration: BoxDecoration(color: RAccent.meter700),
                          child: SizedBox(width: RMotif.tabIndicatorWidth, height: RMotif.tabIndicatorHeight),
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
