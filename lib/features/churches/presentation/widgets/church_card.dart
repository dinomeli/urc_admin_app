import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../data/models/church.dart';

class ChurchCard extends StatelessWidget {
  final Church church;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ChurchCard({
    super.key,
    required this.church,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 6,
      shadowColor: Colors.black.withOpacity(0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {}, // اگر می‌خوای کلیک روی کارت کاری کنه
        splashColor: const Color(0xFF00ADB5).withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.church_rounded,
                    color: const Color(0xFF00ADB5),
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      church.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A), // مشکی تیره برای روح
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.location_city, color: Colors.blueGrey[600], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    church.city,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.blueGrey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.home, color: Colors.blueGrey[600], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      church.address,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.blueGrey[700],
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: const Color(0xFF00ADB5)),
                    onPressed: onEdit,
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red[700]),
                    onPressed: onDelete,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}