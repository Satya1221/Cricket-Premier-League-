import '../domain/auction_state.dart';
import '../domain/player.dart';

AuctionState createDemoAuction() => AuctionState(
  teams: [
    AuctionTeam(id: 'cpl', name: 'Coastal Premier Lions', shortName: 'CPL', purseCr: 120),
    AuctionTeam(id: 'roy', name: 'Royal Strikers', shortName: 'ROY', purseCr: 120),
    AuctionTeam(id: 'tit', name: 'Capital Titans', shortName: 'TIT', purseCr: 120),
    AuctionTeam(id: 'fal', name: 'Frontier Falcons', shortName: 'FAL', purseCr: 120),
  ],
  players: [
    AuctionPlayer(id: 'p001', name: 'Aarav Sen', nation: 'India', role: PlayerRole.batter, overall: 88, potential: 94, basePriceCr: 2, age: 23, batting: 91, bowling: 28, fielding: 82, form: 87),
    AuctionPlayer(id: 'p002', name: 'Zain Mercer', nation: 'South Africa', role: PlayerRole.allRounder, overall: 91, potential: 93, basePriceCr: 2, isOverseas: true, age: 27, batting: 88, bowling: 89, fielding: 86, form: 90),
    AuctionPlayer(id: 'p003', name: 'Dev Malhotra', nation: 'India', role: PlayerRole.bowler, overall: 86, potential: 95, basePriceCr: 1.5, age: 21, batting: 30, bowling: 92, fielding: 77, form: 83),
    AuctionPlayer(id: 'p004', name: 'Kiran Das', nation: 'India', role: PlayerRole.wicketKeeper, overall: 84, potential: 92, basePriceCr: 1, age: 22, batting: 85, bowling: 18, fielding: 89, form: 81),
  ],
  currentPlayerIndex: 0,
  phase: AuctionPhase.ready,
  currentBidCr: 0,
  leadingTeamId: null,
  bidHistory: [],
  message: 'Opening lot • scouting reports loaded',
);
