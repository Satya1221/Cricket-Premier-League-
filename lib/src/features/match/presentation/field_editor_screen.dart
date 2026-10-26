import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/game_theme.dart';
import '../../game/application/field_placement_provider.dart';
import '../../match/domain/field_placement_engine.dart';

class FieldEditorScreen extends ConsumerStatefulWidget {
  const FieldEditorScreen({super.key});

  @override
  ConsumerState<FieldEditorScreen> createState() => _FieldEditorScreenState();
}

class _FieldEditorScreenState extends ConsumerState<FieldEditorScreen> {
  String selected = 'WK';

  @override
  Widget build(BuildContext context) {
    final field = ref.watch(fieldPlacementProvider);
    final controller = ref.read(fieldPlacementProvider.notifier);
    return Scaffold(
      backgroundColor: GamePalette.ink,
      appBar: AppBar(title: const Text('FIELD PLACEMENT')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'TAP THE OVAL TO MOVE THE SELECTED FIELDER',
            style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          const Text('TACTICAL PRESETS', style: TextStyle(color: GamePalette.gold, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: FieldPreset.values
                .map((preset) => ActionChip(
                      label: Text(preset.label),
                      onPressed: () => controller.applyPreset(preset),
                    ))
                .toList(),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: field.fielders
                .map((f) => ChoiceChip(
                      label: Text(f.playerId),
                      selected: selected == f.playerId,
                      onSelected: (_) => setState(() => selected = f.playerId),
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),
          AspectRatio(
            aspectRatio: .86,
            child: LayoutBuilder(
              builder: (context, constraints) => GestureDetector(
                onTapDown: (details) {
                  final x = (details.localPosition.dx / constraints.maxWidth).clamp(.02, .98);
                  final y = (details.localPosition.dy / constraints.maxHeight).clamp(.02, .98);
                  final old = field.fielders.where((f) => f.playerId == selected).firstOrNull;
                  controller.move(selected, x, y, old?.role ?? FieldPositionRole.innerRing);
                },
                child: CustomPaint(
                  painter: _OvalPainter(field.fielders, selected),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text('FIELDER ROLE', style: TextStyle(color: GamePalette.gold, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: FieldPositionRole.values
                .map((role) => ActionChip(
                      label: Text(role.name),
                      onPressed: () {
                        final f = field.fielders.where((f) => f.playerId == selected).firstOrNull;
                        controller.move(selected, f?.x ?? .5, f?.y ?? .5, role);
                      },
                    ))
                .toList(),
          ),
          const SizedBox(height: 10),
          Text(
            'Fielders placed: ${field.fielders.length}. Coordinates are held in session memory.',
            style: const TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }
}

class _OvalPainter extends CustomPainter {
  _OvalPainter(this.fielders, this.selected);

  final List<FieldFielder> fielders;
  final String selected;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(size.width * .06, size.height * .05, size.width * .88, size.height * .90);
    final grass = Paint()..color = GamePalette.emerald;
    final line = Paint()
      ..color = Colors.white70
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawOval(rect, grass);
    canvas.drawOval(rect.deflate(24), line);
    canvas.drawOval(
      Rect.fromCenter(center: rect.center, width: rect.width * .46, height: rect.height * .40),
      line,
    );
    canvas.drawRect(
      Rect.fromCenter(center: rect.center, width: rect.width * .18, height: rect.height * .10),
      line,
    );
    for (final f in fielders) {
      final p = Offset(rect.left + f.x * rect.width, rect.top + f.y * rect.height);
      canvas.drawCircle(
        p,
        f.playerId == selected ? 12 : 9,
        Paint()..color = f.playerId == selected ? GamePalette.gold : Colors.white,
      );
      final tp = TextPainter(
        text: TextSpan(
          text: f.playerId,
          style: const TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.w900),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, p - Offset(tp.width / 2, tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _OvalPainter oldDelegate) =>
      oldDelegate.fielders != fielders || oldDelegate.selected != selected;
}
