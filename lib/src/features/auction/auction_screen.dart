import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/game_feel.dart';
import '../../core/cricket_currency.dart';
import '../match/matchday_screen.dart';

import '../../theme/game_theme.dart';
import 'application/auction_controller.dart';
import 'domain/auction_engine.dart';
import 'domain/auction_state.dart';
import 'domain/player.dart';

class AuctionScreen extends ConsumerWidget {
  const AuctionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(auctionControllerProvider);
    final actions = ref.read(auctionControllerProvider.notifier);
    final player = state.currentPlayer;
    final remaining = state.teams.fold<double>(0, (sum, team) => sum + team.purseCr);
    return Scaffold(
      appBar: AppBar(
        title: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('CRICKET PREMIER LEAGUE', style: TextStyle(fontSize: 11, letterSpacing: 1.8, color: GamePalette.gold, fontWeight: FontWeight.w900)),
          Text('LIVE AUCTION', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
        ]),
        actions: [IconButton(tooltip: 'Matchday', onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const MatchdayScreen())), icon: const Icon(Icons.sports_cricket_rounded)), IconButton(tooltip: 'Reset demo auction', onPressed: actions.reset, icon: const Icon(Icons.restart_alt))],
      ),
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          final wide = constraints.maxWidth >= 720;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 28),
            children: [
              const _HeroBanner(),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: _Metric(label: 'FRANCHISES', value: '${state.teams.length}', icon: Icons.shield_outlined)),
                const SizedBox(width: 8),
                Expanded(child: _Metric(label: 'PURSE REMAINING', value: '₹${remaining.toStringAsFixed(1)} Cr', icon: Icons.account_balance_wallet_outlined, accent: GamePalette.emerald)),
                const SizedBox(width: 8),
                Expanded(child: _Metric(label: 'TOTAL BUDGET', value: '₹${(state.teams.length * 120).toStringAsFixed(0)} Cr', icon: Icons.monetization_on_outlined)),
              ]),
              const SizedBox(height: 18),
              if (player == null)
                const _AuctionComplete()
              else ...[
                _PlayerLot(player: player, state: state),
                const SizedBox(height: 14),
                if (wide)
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(child: _TeamWarRoom(state: state, onBid: actions.bidFor)),
                    const SizedBox(width: 14),
                    Expanded(child: _AuctionFeed(state: state)),
                  ])
                else ...[
                  _TeamWarRoom(state: state, onBid: actions.bidFor),
                  const SizedBox(height: 14),
                  _AuctionFeed(state: state),
                ],
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: state.phase == AuctionPhase.ready || state.phase == AuctionPhase.bidding
                        ? () => actions.runRivalRound()
                        : null,
                    icon: const Icon(Icons.psychology_alt_rounded),
                    label: const Text('SIMULATE RIVAL AI ROUND'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: GamePalette.emerald,
                      side: const BorderSide(color: GamePalette.emerald),
                      minimumSize: const Size(48, 48),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _ManagerDeck(
                  state: state,
                  onBid: () {
                    try {
                      actions.bidFor('cpl');
                    } on StateError catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.message)),
                      );
                    }
                  },
                ),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: OutlinedButton.icon(
                    onPressed: state.phase == AuctionPhase.ready || state.phase == AuctionPhase.bidding ? () {
                      try { actions.closeLot(); } on StateError catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
                      }
                    } : null,
                    icon: const Icon(Icons.gavel_rounded),
                    label: Text(state.leadingTeamId == null ? 'CLOSE AS UNSOLD' : 'HAMMER • CONFIRM SALE'),
                    style: OutlinedButton.styleFrom(foregroundColor: GamePalette.gold, side: const BorderSide(color: GamePalette.gold), minimumSize: const Size(48, 52)),
                  )),
                  const SizedBox(width: 8),
                  Expanded(child: ElevatedButton.icon(
                    onPressed: state.phase == AuctionPhase.sold || state.phase == AuctionPhase.unsold ? actions.nextLot : null,
                    icon: const Icon(Icons.skip_next_rounded),
                    label: const Text('NEXT PLAYER'),
                  )),
                ]),
              ],
              const SizedBox(height: 18),
              const Wrap(spacing: 8, runSpacing: 8, children: [
                _Tag(icon: Icons.psychology_alt_outlined, label: 'PLAYER INTELLIGENCE'),
                _Tag(icon: Icons.trending_up, label: 'DYNAMIC VALUE'),
                _Tag(icon: Icons.groups_2_outlined, label: 'SQUAD BUILDING'),
                _Tag(icon: Icons.sports_cricket, label: 'MATCH ENGINE NEXT'),
              ]),
            ],
          );
        }),
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(22),
      gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [Color(0xFF243A3B), Color(0xFF13242C), Color(0xFF111821)]),
      border: Border.all(color: GamePalette.gold.withValues(alpha: .32)),
    ),
    child: Stack(children: [
      const Positioned(right: 0, top: -8, child: Icon(Icons.stadium_rounded, size: 98, color: Color(0x223DDEAA))),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('THE NEXT GENERATION OF FRANCHISE CRICKET', style: TextStyle(color: GamePalette.emerald, fontSize: 10, letterSpacing: 1.1, fontWeight: FontWeight.w900)),
        const SizedBox(height: 12),
        const Text('Build a dynasty.', style: TextStyle(fontSize: 31, height: 1, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        Text('Every bid shapes your legacy.', style: TextStyle(color: Colors.white.withValues(alpha: .72))),
        const SizedBox(height: 15),
        const Wrap(spacing: 8, runSpacing: 8, children: [
          _Tag(icon: Icons.bolt, label: 'LIVE BIDDING'),
          _Tag(icon: Icons.insights, label: 'RIVAL STRATEGIES'),
        ]),
      ]),
    ]),
  );
}

class _Tag extends StatelessWidget {
  const _Tag({required this.icon, required this.label});
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
    decoration: BoxDecoration(color: Colors.black.withValues(alpha: .22), borderRadius: BorderRadius.circular(9), border: Border.all(color: Colors.white12)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 13, color: GamePalette.gold),
      const SizedBox(width: 5),
      Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: .4)),
    ]),
  );
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, required this.icon, this.accent = GamePalette.gold});
  final String label, value;
  final IconData icon;
  final Color accent;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(11),
    decoration: BoxDecoration(color: GamePalette.panel, borderRadius: BorderRadius.circular(14), border: Border.all(color: GamePalette.line)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 16, color: accent),
      const SizedBox(height: 9),
      Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
      const SizedBox(height: 4),
      Text(label, maxLines: 2, style: const TextStyle(fontSize: 9, letterSpacing: .3, color: GamePalette.muted, fontWeight: FontWeight.w800)),
    ]),
  );
}

class _PlayerLot extends StatelessWidget {
  const _PlayerLot({required this.player, required this.state});
  final AuctionPlayer player;
  final AuctionState state;
  @override
  Widget build(BuildContext context) {
    final currentBid = state.currentBidCr;
    final phase = state.phase;
    final valuation = const AuctionEngine().valuationCr(player);
    return _Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('PLAYER ON THE BLOCK', style: TextStyle(fontSize: 10, letterSpacing: 1.1, color: GamePalette.muted, fontWeight: FontWeight.w800)),
        Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6), decoration: BoxDecoration(color: GamePalette.gold.withValues(alpha: .13), borderRadius: BorderRadius.circular(8)), child: Text(player.roleLabel, style: const TextStyle(color: GamePalette.gold, fontSize: 9, fontWeight: FontWeight.w900))),
      ]),
      const SizedBox(height: 18),
      Row(children: [
        Container(width: 76, height: 86, decoration: BoxDecoration(color: GamePalette.panelRaised, borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.person_rounded, size: 56, color: GamePalette.gold)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(player.name, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900)),
          Text('${player.nation} • Age ${player.age}${player.isOverseas ? ' • OVERSEAS' : ''}', style: const TextStyle(color: GamePalette.muted, fontSize: 11)),
          const SizedBox(height: 10),
          Wrap(spacing: 6, runSpacing: 6, children: [
            _Rating(label: 'OVR', value: player.overall),
            _Rating(label: 'POT', value: player.potential),
            _Rating(label: 'FORM', value: player.form),
          ]),
        ])),
      ]),
      const Divider(height: 28, color: GamePalette.line),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        _Price(label: 'BASE PRICE', value: CricketCurrency.format(player.basePriceCr)),
        _Price(label: 'CURRENT BID', value: currentBid == 0 ? '—' : CricketCurrency.format(currentBid), highlight: true),
        _Price(label: 'EST. VALUE', value: CricketCurrency.format(valuation)),
      ]),
      if (phase == AuctionPhase.sold) ...[
        const SizedBox(height: 12),
        Center(
          child: Text(
            'SOLD TO\n${state.teams.where((team) => team.id == state.leadingTeamId).firstOrNull?.name.toUpperCase() ?? 'FRANCHISE'}',
            key: ValueKey('sold-${player.name}'),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 30, height: 1.05, fontWeight: FontWeight.w900, color: GamePalette.gold),
          )
              .animate()
              .scale(begin: const Offset(2.2, 2.2), end: const Offset(1, 1), curve: Curves.easeInQuint, duration: 250.ms)
              .callback(callback: (_) => GameFeel.triggerGavelSlam())
              .shake(hz: 8, curve: Curves.easeOut, duration: 400.ms)
              .shimmer(delay: 200.ms, duration: 800.ms, color: Colors.white),
        ),
      ],
      const SizedBox(height: 12),
      Text(switch (phase) {
        AuctionPhase.ready => 'SCOUTING DOSSIER READY',
        AuctionPhase.bidding => 'BIDDING WAR IN PROGRESS',
        AuctionPhase.sold => 'LOT SOLD',
        AuctionPhase.unsold => 'LOT UNSOLD',
        AuctionPhase.completed => 'AUCTION COMPLETE',
      }, style: const TextStyle(color: GamePalette.emerald, fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.w900)),
    ]));
  }
}

class _Rating extends StatelessWidget {
  const _Rating({required this.label, required this.value});
  final String label;
  final int value;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    decoration: BoxDecoration(color: Colors.white.withValues(alpha: .04), borderRadius: BorderRadius.circular(8)),
    child: Text('$label  $value', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
  );
}

class _Price extends StatelessWidget {
  const _Price({required this.label, required this.value, this.highlight = false});
  final String label, value;
  final bool highlight;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(fontSize: 9, color: GamePalette.muted, letterSpacing: .3, fontWeight: FontWeight.w800)),
    const SizedBox(height: 4),
    Text(value, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: highlight ? GamePalette.gold : Colors.white)),
  ]);
}

class _TeamWarRoom extends StatelessWidget {
  const _TeamWarRoom({required this.state, required this.onBid});
  final AuctionState state;
  final ValueChanged<String> onBid;
  @override
  Widget build(BuildContext context) => _Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('FRANCHISE WAR ROOM', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: .7)),
    const SizedBox(height: 4),
    const Text('Choose a franchise to place its next bid.', style: TextStyle(color: GamePalette.muted, fontSize: 11)),
    const SizedBox(height: 12),
    for (final team in state.teams)
      Padding(padding: const EdgeInsets.only(bottom: 8), child: _TeamRow(
        team: team, leading: team.id == state.leadingTeamId,
        enabled: state.phase == AuctionPhase.ready || state.phase == AuctionPhase.bidding,
        onTap: () {
          try { onBid(team.id); } on StateError catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
          }
        },
      )),
  ]));
}

class _TeamRow extends StatelessWidget {
  const _TeamRow({required this.team, required this.leading, required this.enabled, required this.onTap});
  final AuctionTeam team;
  final bool leading, enabled;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: enabled ? onTap : null,
    borderRadius: BorderRadius.circular(13),
    child: Container(padding: const EdgeInsets.all(11), decoration: BoxDecoration(
      color: leading ? GamePalette.gold.withValues(alpha: .10) : GamePalette.panelRaised.withValues(alpha: .5),
      borderRadius: BorderRadius.circular(13),
      border: Border.all(color: leading ? GamePalette.gold.withValues(alpha: .55) : GamePalette.line),
    ), child: Row(children: [
      Container(width: 39, height: 39, alignment: Alignment.center, decoration: BoxDecoration(
        color: leading ? GamePalette.gold : GamePalette.ink, borderRadius: BorderRadius.circular(10)),
        child: Text(team.shortName, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: leading ? GamePalette.ink : GamePalette.gold))),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(team.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
        const SizedBox(height: 3),
        Text('Purse ${CricketCurrency.format(team.purseCr)} • Squad ${team.squad.length}', style: const TextStyle(color: GamePalette.muted, fontSize: 10)),
      ])),
      Icon(leading ? Icons.local_fire_department : Icons.add_circle_outline, color: leading ? GamePalette.gold : GamePalette.emerald),
    ])),
  );
}

class _ManagerDeck extends StatelessWidget {
  const _ManagerDeck({required this.state, required this.onBid});
  final AuctionState state;
  final VoidCallback onBid;

  @override
  Widget build(BuildContext context) {
    final team = state.teams.where((team) => team.id == 'cpl').firstOrNull;
    final player = state.currentPlayer;
    final nextBid = state.currentBidCr == 0
        ? (player?.basePriceCr ?? 0)
        : state.currentBidCr + const AuctionEngine().incrementFor(state.currentBidCr);
    final active = state.phase == AuctionPhase.ready || state.phase == AuctionPhase.bidding;
    final canAfford = team != null && team.purseCr >= nextBid;
    final alreadyLeading = state.leadingTeamId == 'cpl';
    final canBid = active && player != null && canAfford && !alreadyLeading &&
        team.remainingSlots > 0 &&
        (!player.isOverseas || team.overseasCount < team.maxOverseas);

    return _Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('MANAGER’S DECK', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: .8)),
      const SizedBox(height: 12),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('Your franchise • CPL', style: TextStyle(color: GamePalette.muted, fontSize: 12)),
        Text(CricketCurrency.format(team?.purseCr ?? 0),
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: GamePalette.gold)),
      ]),
      const SizedBox(height: 5),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('Next bid', style: TextStyle(color: GamePalette.muted, fontSize: 12)),
        Text(CricketCurrency.format(nextBid), style: const TextStyle(fontWeight: FontWeight.w800)),
      ]),
      const SizedBox(height: 14),
      SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton.icon(
          onPressed: canBid ? () { GameFeel.triggerBidTick(); onBid(); } : null,
          icon: const Icon(Icons.gavel_rounded),
          label: Text(
            !active ? 'LOT CLOSED' :
            alreadyLeading ? 'YOU HOLD THE BID' :
            !canAfford ? 'INSUFFICIENT PURSE' :
            team.remainingSlots <= 0 ? 'SQUAD FULL' :
            player != null && player.isOverseas && team.overseasCount >= team.maxOverseas
                ? 'OVERSEAS LIMIT REACHED'
                : 'PLACE BID • ${CricketCurrency.format(nextBid).toUpperCase()}',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: .3),
          ),
        ),
      ),
      const SizedBox(height: 7),
      const Text('Rival franchises are controlled by the auction AI. Simulate their responses above.',
        style: TextStyle(fontSize: 10, color: GamePalette.muted)),
    ]));
  }
}

class _AuctionFeed extends StatelessWidget {
  const _AuctionFeed({required this.state});
  final AuctionState state;
  @override
  Widget build(BuildContext context) => _Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('AUCTION FEED', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: .7)),
    const SizedBox(height: 12),
    if (state.bidHistory.isEmpty)
      const Text('Bids and decisions will appear here.', style: TextStyle(color: GamePalette.muted, fontSize: 12)),
    for (final event in state.bidHistory.reversed.take(8))
      Padding(padding: const EdgeInsets.only(bottom: 9), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.radio_button_checked, size: 14, color: GamePalette.emerald),
        const SizedBox(width: 8),
        Expanded(child: Text(event, style: const TextStyle(fontSize: 12, height: 1.3))),
      ])),
    const Divider(height: 22, color: GamePalette.line),
    Text(state.message, style: const TextStyle(color: GamePalette.gold, fontSize: 11, fontWeight: FontWeight.w700)),
  ]));
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity, padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: GamePalette.panel, borderRadius: BorderRadius.circular(18), border: Border.all(color: GamePalette.line)),
    child: child,
  );
}

class _AuctionComplete extends StatelessWidget {
  const _AuctionComplete();
  @override
  Widget build(BuildContext context) => const _Panel(child: Column(children: [
    Icon(Icons.emoji_events_rounded, size: 56, color: GamePalette.gold),
    SizedBox(height: 12),
    Text('AUCTION COMPLETE', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
    SizedBox(height: 8),
    Text('Your next dynasty starts with the squad you built.', textAlign: TextAlign.center, style: TextStyle(color: GamePalette.muted)),
  ]));
}
