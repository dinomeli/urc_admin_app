import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/locale_provider.dart';
import '../providers/schedule_provider.dart';
import '../widgets/loading_widget.dart';
import 'package:fluttertoast/fluttertoast.dart';

class GenerateScheduleScreen extends ConsumerStatefulWidget {
  const GenerateScheduleScreen({super.key});

  @override
  ConsumerState<GenerateScheduleScreen> createState() => _GenerateScheduleScreenState();
}

class _GenerateScheduleScreenState extends ConsumerState<GenerateScheduleScreen> {
  int _weeksCount = 8;
  bool _includeCommunion = true;

  @override
  Widget build(BuildContext context) {
    final tr = ref.watch(localeProvider).translate;
    return Scaffold(
      appBar: AppBar(title: Text(tr('Generate Schedules', 'تولید برنامه‌ها'))),
      body: Padding(
        padding: const EdgeEdges.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(tr('Weeks', 'هفته‌ها')),
            Slider(
              value: _weeksCount.toDouble(),
              min: 1,
              max: 52,
              divisions: 51,
              label: _weeksCount.toString(),
              onChanged: (value) => setState(() => _weeksCount = value.toInt()),
            ),
            SwitchListTile(
              title: Text(tr('Include Communion', 'شامل عشای ربانی')),
              value: _includeCommunion,
              onChanged: (value) => setState(() => _includeCommunion = value),
            ),
            ElevatedButton(
              onPressed: () async {
                final repo = ref.read(scheduleRepositoryProvider);
                try {
                  await repo.generateSchedules(_weeksCount, _includeCommunion);
                  Fluttertoast.showToast(msg: tr('Generated', 'تولید شد'));
                  Navigator.pop(context);
                  ref.refresh(schedulesProvider);
                } catch (e) {
                  Fluttertoast.showToast(msg: tr('Error', 'خطا'));
                }
              },
              child: Text(tr('Generate', 'تولید')),
            ),
          ],
        ),
      ),
    );
  }
}