import 'package:flutter_test/flutter_test.dart';
import 'package:cricket_premier_league/src/core/cricket_currency.dart';
import 'package:cricket_premier_league/src/core/display_labels.dart';

void main() {
  group('DisplayLabels', () {
    test('expands abbreviations and enum names into readable cricket language', () {
      expect(DisplayLabels.display('TMP'), 'Temperament');
      expect(DisplayLabels.display('DTH'), 'Death-overs skill');
      expect(DisplayLabels.display('allRounder'), 'All-rounder');
      expect(DisplayLabels.display('wicketKeeper'), 'Wicketkeeper');
      expect(DisplayLabels.display('noBall'), 'No-ball');
      expect(DisplayLabels.display('run_rate'), 'Run Rate');
    });

    test('provides useful hints only where extra explanation exists', () {
      expect(DisplayLabels.hint('RAT'), contains('current ability'));
      expect(DisplayLabels.hint('unknownField'), isNull);
    });
  });

  group('CricketCurrency.formatRupees', () {
    test('uses Indian digit grouping', () {
      expect(CricketCurrency.formatRupees(0), '₹0');
      expect(CricketCurrency.formatRupees(1234), '₹1,234');
      expect(CricketCurrency.formatRupees(1234567), '₹12,34,567');
      expect(CricketCurrency.formatRupees(-12345), '−₹12,345');
    });

    test('handles non-finite amounts safely', () {
      expect(CricketCurrency.formatRupees(double.nan), '₹—');
      expect(CricketCurrency.formatRupees(double.infinity), '₹—');
    });
  });
}
