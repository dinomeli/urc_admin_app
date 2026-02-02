import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/locale_provider.dart';
import '../widgets/assignment_tile.dart';
import '../widgets/loading_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:syncfusion_flutter_pdfviewer/syncfusion_flutter_pdfviewer.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ScheduleDetailScreen extends ConsumerWidget {
  final int scheduleId;
  const ScheduleDetailScreen({super.key, required this.scheduleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = ref.watch(localeProvider).translate;
    final scheduleAsync = ref.watch(scheduleDetailProvider(scheduleId));

    return Scaffold(
      appBar: AppBar(
        title: Text(tr('Detail', 'جزئیات')),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () async {
              final repo = ref.read(scheduleRepositoryProvider);
              try {
                final response = await repo.exportPdf(scheduleId);
                final dir = await getTemporaryDirectory();
                final path = '${dir.path}/schedule_$scheduleId.pdf';
                final file = File(path);
                await file.writeAsBytes(response.data);
                Navigator.push(context, MaterialPageRoute(builder: (context) => PdfViewerScreen(path: path)));
              } catch (e) {
                Fluttertoast.showToast(msg: tr('Error downloading PDF', 'خطا در دانلود PDF'));
              }
            },
          ),
          // دکمه اکسل اگر لازم
        ],
      ),
      body: scheduleAsync.when(
        data: (schedule) => ListView.builder(
          itemCount: schedule.assignments.length,
          itemBuilder: (context, index) => AssignmentTile(
            assignment: schedule.assignments[index],
            onRemove: () async {
              final repo = ref.read(scheduleRepositoryProvider);
              await repo.removeAssignment(schedule.assignments[index].id);
              ref.refresh(scheduleDetailProvider(scheduleId));
              Fluttertoast.showToast(msg: tr('Removed', 'حذف شد'));
            },
            onUpdate: (newUserId) async {
              final repo = ref.read(scheduleRepositoryProvider);
              await repo.updateAssignment(schedule.assignments[index].id, newUserId);
              ref.refresh(scheduleDetailProvider(scheduleId));
              Fluttertoast.showToast(msg: tr('Updated', 'بروز شد'));
            },
          ),
        ),
        loading: () => const LoadingWidget(),
        error: (err, stack) => Center(child: Text(tr('Error', 'خطا'))),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // دیالوگ اضافه assignment
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text(tr('Add Assignment', 'افزودن تخصیص')),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // dropdown نقش و کاربر
                  // سپس repo.addAssignment(scheduleId, roleId, userId)
                ],
              ),
            ),
          ).then((_) => ref.refresh(scheduleDetailProvider(scheduleId)));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}