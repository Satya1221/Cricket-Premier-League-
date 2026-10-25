import 'package:flutter_test/flutter_test.dart';
import 'package:cricket_premier_league/providers/match_provider.dart';

void main(){
 group('IPL T20 MatchNotifier',(){
  late MatchNotifier match;
  setUp((){
   match=MatchNotifier();
   match.selectOpeningBatters(strikerId:'b1',nonStrikerId:'b2');
   match.selectNewBowler('bowler1');
  });
  test('wide adds penalty and does not consume a legal ball or rotate for penalty alone',(){
   match.resolveDelivery(0,false,'Wide');
   expect(match.state.runs,1);
   expect(match.state.legalBalls,0);
   expect(match.state.strikerId,'b1');
  });
  test('odd completed runs rotate strike',(){
   match.resolveDelivery(1,false,'None');
   expect(match.state.strikerId,'b2');
   expect(match.state.nonStrikerId,'b1');
   expect(match.state.legalBalls,1);
  });
  test('no-ball penalty does not consume legal ball',(){
   match.resolveDelivery(0,false,'NoBall');
   expect(match.state.runs,1);
   expect(match.state.legalBalls,0);
   expect(match.state.strikerId,'b1');
  });
  test('six legal balls trigger over transition and new bowler selection',(){
   for(var i=0;i<6;i++)match.resolveDelivery(0,false,'None');
   expect(match.state.legalBalls,6);
   expect(match.state.pendingBowlerChange,true);
   expect(match.state.message,'Over complete. Select a new bowler.');
   match.selectNewBowler('bowler2');
   expect(match.state.bowlerId,'bowler2');
   expect(match.state.pendingBowlerChange,false);
  });
 });
}
