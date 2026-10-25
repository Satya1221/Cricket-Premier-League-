import '../models/fixture_model.dart';

class FixtureGeneratorService {
  const FixtureGeneratorService();

  List<FixtureModel> generate(List<String> franchiseIds, {int season = 1}) {
    final ids = franchiseIds.toSet().toList();
    if (ids.length < 2) return const [];
    final slots = <String?>[...ids, if (ids.length.isOdd) null];
    final n = slots.length;
    final firstLeg = <FixtureModel>[];
    for (var round = 0; round < n - 1; round++) {
      for (var i = 0; i < n ~/ 2; i++) {
        final a = slots[i], b = slots[n - 1 - i];
        if (a == null || b == null) continue;
        final home = round.isEven ? a : b, away = round.isEven ? b : a;
        firstLeg.add(FixtureModel(matchId:'S${season}-W${round+1}-${home}-${away}',homeTeamId:home,awayTeamId:away,matchWeek:round+1));
      }
      final fixed = slots.first;
      final rotating = slots.sublist(1);
      rotating.insert(0, rotating.removeLast());
      slots..clear()..add(fixed)..addAll(rotating);
    }
    return [...firstLeg, ...firstLeg.map((f)=>FixtureModel(
      matchId:'S${season}-W${f.matchWeek+n-1}-${f.awayTeamId}-${f.homeTeamId}',
      homeTeamId:f.awayTeamId,awayTeamId:f.homeTeamId,matchWeek:f.matchWeek+n-1))];
  }
}
