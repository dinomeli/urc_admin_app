import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../data/models/user_dto.dart';
// فرض بر این است که CreateUserDto و UpdateUserDto در این مسیر هستند
import '../../data/models/user_dto.dart';

class UsersListScreen extends StatefulWidget {
  const UsersListScreen({super.key});

  @override
  State<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<UserProvider>().fetchUsers());
  }

  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<LocaleProvider>(context);
    final tr = locale.translate;
    final userProvider = Provider.of<UserProvider>(context);
    final isFa = locale.locale.languageCode == 'fa';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.teal.shade900,
        title: Text(
          tr('Users Management', 'مدیریت کاربران'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => userProvider.fetchUsers(),
          ),
        ],
      ),
      body: userProvider.isLoading && userProvider.users.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : userProvider.error != null
          ? _buildErrorWidget(userProvider.error!, tr)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: userProvider.users.length,
              itemBuilder: (context, index) {
                final user = userProvider.users[index];
                return _buildUserCard(user, isFa, tr);
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: () => _showCreateUserSheet(context, tr),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  // --- ویجت کارت کاربر ---
  Widget _buildUserCard(UserDto user, bool isFa, Function tr) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.teal.shade50,
                  child: Text(
                    user.initial,
                    style: TextStyle(
                      color: Colors.teal.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        user.email ?? '',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.edit_note,
                    color: Colors.teal.shade700,
                    size: 28,
                  ),
                  onPressed: () => _showActionMenu(context, user, tr),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _infoRow(Icons.phone_android, user.phoneString),
                    _buildStatusBadge(user.isActive ?? false, isFa, tr),
                  ],
                ),

                // --- این دقیقاً همان بخشی است که در کد قبلی حذف شده بود ---
                if (user.roles != null && user.roles!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: user.roles!
                          .map((role) => _roleChip(role))
                          .toList(),
                    ),
                  ),
                ],
                // -------------------------------------------------------
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- منوی عملیات ---
  void _showActionMenu(BuildContext context, UserDto user, Function tr) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.person_outline, color: Colors.blue),
            title: Text(tr('Edit Profile', 'ویرایش مشخصات')),
            onTap: () {
              Navigator.pop(context);
              _showUpdateUserSheet(context, user, tr);
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.admin_panel_settings_outlined,
              color: Colors.orange,
            ),
            title: Text(tr('Manage Roles', 'مدیریت نقش‌ها')),
            onTap: () {
              Navigator.pop(context);
              _showRolesManagementSheet(context, user, tr);
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.delete_forever_outlined,
              color: Colors.red,
            ),
            title: Text(tr('Delete User', 'حذف کاربر')),
            onTap: () {
              Navigator.pop(context);
              _showDeleteConfirmation(context, user, tr);
            },
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _roleChip(String role) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.teal.shade500,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        role,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // --- فرم افزودن کاربر جدید ---
  void _showCreateUserSheet(BuildContext context, Function tr) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();
    String? selectedGender; // مدل شما این را اختیاری گرفته است

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tr('Add New User', 'افزودن کاربر جدید'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                _buildField(emailController, tr('Email', 'ایمیل')),
                _buildField(
                  passwordController,
                  tr('Password', 'رمز عبور'),
                  isObscure: true,
                ),
                _buildField(firstNameController, tr('First Name', 'نام')),
                _buildField(
                  lastNameController,
                  tr('Last Name', 'نام خانوادگی'),
                ),
                _buildField(phoneController, tr('Phone', 'تلفن')),
                _buildField(addressController, tr('Address', 'آدرس')),

                // انتخاب جنسیت مطابق مدل شما
                DropdownButtonFormField<String>(
                  value: selectedGender,
                  decoration: InputDecoration(
                    labelText: tr('Gender', 'جنسیت'),
                    border: const OutlineInputBorder(),
                  ),
                  items: ['Male', 'Female']
                      .map(
                        (g) => DropdownMenuItem(
                          value: g,
                          child: Text(tr(g, g == 'Male' ? 'مرد' : 'زن')),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => setSheetState(() => selectedGender = val),
                ),

                const SizedBox(height: 20),
                _buildSubmitButton(tr('Create User', 'ثبت کاربر'), () async {
                  // چک کردن فیلدهای اجباری مدل شما
                  if (emailController.text.isEmpty ||
                      passwordController.text.isEmpty ||
                      firstNameController.text.isEmpty ||
                      lastNameController.text.isEmpty ||
                      phoneController.text.isEmpty ||
                      addressController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          tr(
                            'Please fill all required fields',
                            'لطفاً تمام فیلدها را پر کنید',
                          ),
                        ),
                      ),
                    );
                    return;
                  }

                  final newUser = CreateUserDto(
                    email: emailController.text,
                    password: passwordController.text,
                    firstName: firstNameController.text,
                    lastName: lastNameController.text,
                    phone: phoneController.text,
                    address: addressController.text,
                    gender: selectedGender,
                  );

                  await context.read<UserProvider>().createUser(newUser);

                  if (context.mounted) {
                    if (context.read<UserProvider>().error == null) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.green,
                          content: Text(tr('User created', 'کاربر ایجاد شد')),
                        ),
                      );
                    }
                  }
                }),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- فرم ویرایش کاربر ---
  void _showUpdateUserSheet(BuildContext context, UserDto user, Function tr) {
    final fName = TextEditingController(text: user.firstName);
    final lName = TextEditingController(text: user.lastName);
    final phone = TextEditingController(text: user.phoneString);
    final email = TextEditingController(text: user.email ?? '');
    final address = TextEditingController(text: user.address ?? '');
    bool isActive = user.isActive ?? true;
    String? selectedGender = user.gender;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tr('Edit Profile', 'ویرایش مشخصات'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),

                _buildField(email, tr('Email', 'ایمیل')),
                _buildField(fName, tr('First Name', 'نام')),
                _buildField(lName, tr('Last Name', 'نام خانوادگی')),
                _buildField(phone, tr('Phone', 'تلفن')),
                _buildField(address, tr('Address', 'آدرس')),

                // انتخاب جنسیت
                DropdownButtonFormField<String>(
                  value: selectedGender,
                  decoration: InputDecoration(
                    labelText: tr('Gender', 'جنسیت'),
                    border: const OutlineInputBorder(),
                  ),
                  items: ['Male', 'Female']
                      .map(
                        (g) => DropdownMenuItem(
                          value: g,
                          child: Text(tr(g, g == 'Male' ? 'مرد' : 'زن')),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => setSheetState(() => selectedGender = val),
                ),

                // وضعیت فعال بودن
                SwitchListTile(
                  title: Text(tr('Active Status', 'وضعیت فعالیت')),
                  value: isActive,
                  onChanged: (val) => setSheetState(() => isActive = val),
                ),

                const SizedBox(height: 20),
                _buildSubmitButton(tr('Save', 'ذخیره تغییرات'), () async {
                  // تمام پارامترهای مدل شما اینجا پاس داده شده تا خطای required برطرف شود
                  final dto = UpdateUserDto(
                    email: email.text,
                    firstName: fName.text,
                    lastName: lName.text,
                    phone: phone.text,
                    address: address.text,
                    isActive: isActive,
                    gender: selectedGender,
                  );

                  await context.read<UserProvider>().updateUser(user.id, dto);
                  if (context.mounted) Navigator.pop(context);
                }),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- مدیریت نقش‌ها ---
  void _showRolesManagementSheet(
    BuildContext context,
    UserDto user,
    Function tr,
  ) {
    final allRoles = [
      'Admin',
      'GroupLeader',
      'Member',
      'Scheduler',
      'Treasurer',
    ];
    List<String> selectedRoles = List.from(user.roles ?? []);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                tr('Manage Roles', 'مدیریت نقش‌ها'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: ListView(
                  children: allRoles
                      .map(
                        (r) => CheckboxListTile(
                          title: Text(r),
                          value: selectedRoles.contains(r),
                          onChanged: (v) => setSheetState(
                            () => v!
                                ? selectedRoles.add(r)
                                : selectedRoles.remove(r),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              _buildSubmitButton(tr('Update', 'بروزرسانی'), () async {
                await context.read<UserProvider>().updateRoles(
                  user.id,
                  selectedRoles,
                );
                if (context.mounted) Navigator.pop(context);
              }),
            ],
          ),
        ),
      ),
    );
  }

  // --- تاییدیه حذف ---
  void _showDeleteConfirmation(
    BuildContext context,
    UserDto user,
    Function tr,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr('Delete User', 'حذف کاربر')),
        content: Text(tr('Are you sure?', 'آیا مطمئن هستید؟')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr('Cancel', 'لغو')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await context.read<UserProvider>().deleteUser(user.id);
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(
              tr('Delete', 'حذف'),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // --- ابزارهای کمکی UI ---
  Widget _buildField(
    TextEditingController controller,
    String label, {
    bool isObscure = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        obscureText: isObscure,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(String label, VoidCallback onPressed) {
    final isLoading = context.watch<UserProvider>().isLoading;
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(label, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive, bool isFa, Function tr) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isActive ? tr('Active', 'فعال') : tr('Inactive', 'غیرفعال'),
        style: TextStyle(
          color: isActive ? Colors.green.shade700 : Colors.red.shade700,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) => Row(
    children: [
      Icon(icon, size: 16, color: Colors.blueGrey.shade300),
      const SizedBox(width: 4),
      Text(text, style: const TextStyle(fontSize: 13)),
    ],
  );

  Widget _buildErrorWidget(String error, Function tr) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, size: 60, color: Colors.red),
        Text(error),
        ElevatedButton(
          onPressed: () => context.read<UserProvider>().fetchUsers(),
          child: Text(tr('Retry', 'تلاش مجدد')),
        ),
      ],
    ),
  );
}
