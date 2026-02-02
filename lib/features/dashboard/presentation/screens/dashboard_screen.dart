import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart'; // اضافه شده برای ناوبری
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../common/widgets/custom_drawer.dart';
import '../providers/dashboard_provider.dart';

class DashboardContent extends StatefulWidget {
  const DashboardContent({super.key});

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  @override
  void initState() {
    super.initState();
    // لود اولیه دیتا
    _loadData();
  }

  // متد لود دیتا که هم در ابتدا و هم در Pull-to-Refresh اجرا می‌شود
  Future<void> _loadData() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    
    // اطمینان از لود بودن توکن
    if (auth.token == null || auth.token!.isEmpty) {
      await auth.loadUserData(); 
    }
    
    if (mounted) {
      final token = auth.token ?? "";
      await context.read<DashboardProvider>().fetchDashboardStats(token);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = Provider.of<LocaleProvider>(context).translate;
    final dashboard = context.watch<DashboardProvider>();

    return Scaffold(
      drawer: const CustomDrawer(),
      // قابلیت پایین کشیدن برای رفرش کل صفحه
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: const Color(0xFF00ADB5),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ۱. اپ‌بار منعطف
            _buildAppBar(tr),
            
            // ۲. بخش منوهای سریع (همیشه ثابت و بدون لودینگ)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
              sliver: SliverToBoxAdapter(
                child: _buildQuickActions(tr),
              ),
            ),

            // ۳. بخش محتوای متغیر (آمار، نمودار و لاگ‌ها)
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  if (dashboard.isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (dashboard.error != null)
                    _buildErrorPlaceholder(dashboard.error)
                  else if (dashboard.data != null) ...[
                    _buildStatGrid(dashboard.data!['summary'] ?? dashboard.data!['Summary'] ?? {}, tr),
                    const SizedBox(height: 24),
                    _buildChartCard(dashboard.data!['chartData'] ?? dashboard.data!['ChartData'] ?? {}, tr),
                    const SizedBox(height: 24),
                    _buildRecentLogs(dashboard.data!['recentLogs'] ?? dashboard.data!['RecentLogs'] ?? [], tr),
                  ] else
                    const Center(child: Text("دیتایی یافت نشد / No Data found")),
                  
                  const SizedBox(height: 80), // فاصله برای اسکرول راحت‌تر
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(Function tr) {
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFF00ADB5),
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          tr('Dashboard', 'داشبورد مدیریتی'), 
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00ADB5), Color(0xFF393E46)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
    );
  }

  // بخش منوهای سریع با قابلیت کلیک و جابجایی
  Widget _buildQuickActions(Function tr) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _quickActionItem(Icons.people, tr('Users', 'کاربران'), '/users-list'),
          _quickActionItem(Icons.calendar_month, tr('Schedules', 'برنامه‌ها'), '/schedules-list'),
          _quickActionItem(Icons.send_rounded, tr('Notify', 'اعلان'), '/send-notification'),
          _quickActionItem(Icons.settings_suggest, tr('Settings', 'تنظیمات'), '/church-settings'),
        ],
      ),
    );
  }

  Widget _quickActionItem(IconData icon, String label, String routePath) {
    return InkWell(
      onTap: () => context.push(routePath), // هدایت به صفحه مقصد
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF00ADB5).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF00ADB5), size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildStatGrid(dynamic summary, Function tr) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.6,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        _statItem((summary['users'] ?? summary['Users'] ?? 0).toString(), tr('Users', 'کاربران'), Icons.people, Colors.blue),
        _statItem((summary['events'] ?? summary['Events'] ?? 0).toString(), tr('Events', 'رویدادها'), Icons.event, Colors.orange),
        _statItem((summary['roles'] ?? summary['Roles'] ?? 0).toString(), tr('Roles', 'نقش‌ها'), Icons.admin_panel_settings, Colors.purple),
        _statItem((summary['absences'] ?? summary['Absences'] ?? 0).toString(), tr('Absences', 'غیبت‌ها'), Icons.person_off, Colors.red),
      ],
    );
  }

  Widget _statItem(String val, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(val, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(dynamic chartData, Function tr) {
    final List<dynamic> present = chartData['present'] ?? chartData['Present'] ?? [];
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.show_chart, color: Color(0xFF00ADB5), size: 20),
              const SizedBox(width: 8),
              Text(tr('Attendance Trend', 'روند حضور'), style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 25),
          SizedBox(
            height: 200,
            child: present.isEmpty 
              ? const Center(child: Text("دیتایی برای نمایش وجود ندارد"))
              : LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: present.asMap().entries.map((e) => FlSpot(e.key.toDouble(), (e.value ?? 0).toDouble())).toList(),
                        isCurved: true,
                        color: const Color(0xFF00ADB5),
                        barWidth: 4,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: true), // نمایش نقاط برای دقت بیشتر
                        belowBarData: BarAreaData(
                          show: true, 
                          color: const Color(0xFF00ADB5).withOpacity(0.1)
                        ),
                      )
                    ],
                  ),
                ),
          ),
        ],
      ),
    );
  }

 Widget _buildRecentLogs(List<dynamic> logs, Function tr) {
  if (logs.isEmpty) return const SizedBox();

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.history_edu, color: Color(0xFF00ADB5)),
            const SizedBox(width: 8),
            Text(
              tr('Reminder History', 'تاریخچه یادآوری‌ها'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal, // برای اینکه در صفحه کوچک موبایل جدول بهم نریزد
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(const Color(0xFF393E46)),
            columnSpacing: 20,
            horizontalMargin: 12,
            columns: [
              DataColumn(label: Text(tr('Date', 'تاریخ ثبت'), style: const TextStyle(color: Colors.white))),
              DataColumn(label: Text(tr('Service', 'تاریخ سرویس'), style: const TextStyle(color: Colors.white))),
              DataColumn(label: Text(tr('Emails', 'ایمیل'), style: const TextStyle(color: Colors.white))),
              DataColumn(label: Text(tr('SMS', 'پیامک'), style: const TextStyle(color: Colors.white))),
              DataColumn(label: Text(tr('Errors', 'خطا'), style: const TextStyle(color: Colors.white))),
            ],
            rows: logs.map((log) {
              // استخراج داده‌ها با هندل کردن حروف بزرگ و کوچک (Case-sensitive)
              final createdAt = log['createdAt'] ?? log['CreatedAt'] ?? '---';
              final serviceDate = log['serviceDate'] ?? log['ServiceDate'] ?? '---';
              final emailsSent = (log['emailsSent'] ?? log['EmailsSent'] ?? 0).toString();
              final smsSent = (log['smsSent'] ?? log['SmsSent'] ?? 0).toString();
              final errors = log['errors'] ?? log['Errors'];

              return DataRow(cells: [
                DataCell(Text(createdAt.toString().split('T')[0], style: const TextStyle(fontSize: 11))), // فقط تاریخ را نشان می‌دهد
                DataCell(Text(serviceDate.toString().split('T')[0], style: const TextStyle(fontSize: 11))),
                DataCell(Center(child: Text(emailsSent))),
                DataCell(Center(child: Text(smsSent))),
                DataCell(
                  Center(
                    child: (errors == null || errors.toString().isEmpty)
                        ? const Text('—')
                        : const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 18),
                  ),
                ),
              ]);
            }).toList(),
          ),
        ),
      ),
    ],
  );
}

  Widget _buildErrorPlaceholder(String? error) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Icon(Icons.wifi_off_rounded, size: 60, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text(error ?? "خطا در دریافت اطلاعات", style: const TextStyle(color: Colors.redAccent)),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: _loadData, 
            icon: const Icon(Icons.refresh),
            label: const Text("تلاش مجدد"),
          ),
        ],
      ),
    );
  }
}