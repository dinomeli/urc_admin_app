class AssignmentTile extends StatelessWidget {
  final Assignment assignment;
  final VoidCallback onRemove;
  final Function(String) onUpdate;
  const AssignmentTile({super.key, required this.assignment, required this.onRemove, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return ListTile(
      title: Text(assignment.userName),
      subtitle: Text(assignment.roleName),
      trailing: PopupMenuButton(
        onSelected: (val) {
          if (val == 'remove') onRemove();
          if (val == 'update') {
            // دیالوگ انتخاب کاربر جدید و فراخوانی onUpdate
          }
        },
        itemBuilder: (ctx) => [
          PopupMenuItem(value: 'update', child: Text(s.update)),
          PopupMenuItem(value: 'remove', child: Text(s.remove)),
        ],
      ),
    );
  }
}