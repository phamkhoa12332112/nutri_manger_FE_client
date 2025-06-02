import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nutrients_manager/data/controller/share_pref_controller.dart';
import 'package:nutrients_manager/data/repository/user_repository.dart';
import 'package:nutrients_manager/ui/page/login/login_screen.dart';
import 'package:nutrients_manager/ui/page/profile/widget/calorie_stats_chart.dart';
import 'package:nutrients_manager/utils/app_navigator.dart';
import 'package:nutrients_manager/utils/gaps_manager.dart';

import '../../../data/models/user.dart';
import '../../../utils/divider_manager.dart';
import '../../../utils/sizes_manager.dart';
import '../home/widget/custom_bottom_app_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserDTB? user;
  bool isLoading = true;

  final _activityFactors = {
    1.2: 'Ít vận động',
    1.375: 'Vận động nhẹ',
    1.55: 'Vận động vừa',
    1.725: 'Vận động nhiều',
    1.9: 'Vận động rất nặng',
  };

  @override
  void initState() {
    loadUserData();

    super.initState();
  }

  Future<void> loadUserData() async {
    String uid = SharedPrefsController.getInstance().getUserId();
    final fetchedUser = await UserRepositoryImpl.instance.fetchUserById(uid);
    setState(() {
      user = fetchedUser;
      isLoading = false;
    });
  }

  Future<void> _editField({
    required String title,
    required String field,
    required dynamic currentValue,
  }) async {
    dynamic result;

    if (field == 'gender') {
      result = await showDialog<bool>(
        context: context,
        builder:
            (_) => AlertDialog(
              title: Text('Chọn $title'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<bool>(
                    title: const Text('Nam'),
                    value: true,
                    groupValue: currentValue,
                    onChanged: (val) => Navigator.pop(context, val),
                  ),
                  RadioListTile<bool>(
                    title: const Text('Nữ'),
                    value: false,
                    groupValue: currentValue,
                    onChanged: (val) => Navigator.pop(context, val),
                  ),
                ],
              ),
            ),
      );
    } else if (field == 'levelExercise') {
      result = await showDialog<double>(
        context: context,
        builder:
            (_) => AlertDialog(
              title: Text('Chọn $title'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children:
                    _activityFactors.entries.map((entry) {
                      return RadioListTile<double>(
                        title: Text(entry.value),
                        value: entry.key,
                        groupValue: currentValue,
                        onChanged: (val) => Navigator.pop(context, val),
                      );
                    }).toList(),
              ),
            ),
      );
    } else {
      final controller = TextEditingController(text: currentValue.toString());
      result = await showDialog<String>(
        context: context,
        builder:
            (_) => AlertDialog(
              title: Text('Chỉnh sửa $title'),
              content: TextField(
                controller: controller,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(hintText: 'Nhập $title mới'),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Huỷ'),
                ),
                TextButton(
                  onPressed: () {
                    if (controller.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Vui lòng nhập $title')),
                      );
                      return;
                    }
                    final snackBar = SnackBar(
                      content: Text('$title đã được cập nhật'),
                      duration: Duration(seconds: 2),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);

                    Navigator.pop(context, controller.text);
                  },
                  child: const Text('Lưu'),
                ),
              ],
            ),
      );
    }

    if (result != null && user != null) {
      final updatedUser = user!;

      switch (field) {
        case 'name':
          updatedUser.name = result;
          break;
        case 'height':
          updatedUser.height = double.tryParse(result) ?? updatedUser.height;
          break;
        case 'weight':
          updatedUser.weight = double.tryParse(result) ?? updatedUser.weight;
          break;
        case 'age':
          updatedUser.age = int.tryParse(result) ?? updatedUser.age;
          break;
        case 'gender':
          updatedUser.gender = result;
          break;
        case 'weightGoal':
          updatedUser.weightGoal =
              double.tryParse(result) ?? updatedUser.weightGoal;
          break;
        case 'levelExercise':
          updatedUser.levelExercise = result;
          break;
      }

      await UserRepositoryImpl.instance.patchUserInformation(
        uid: updatedUser.userId,
        name: updatedUser.name!,
        height: updatedUser.height!.toDouble(),
        gender: updatedUser.gender!,
        weight: updatedUser.weight!.toDouble(),
        level: updatedUser.levelExercise!,
        dailyCaloriesGoal: updatedUser.dailyCaloriesGoal!.toDouble(),
        weightGoal: updatedUser.weightGoal!.toDouble(),
        age: updatedUser.age!,
      );

      setState(() {
        user = updatedUser;
      });
    }
  }

  void _changePasswordDialog() {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text('Đổi mật khẩu'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: oldPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(labelText: 'Mật khẩu hiện tại'),
                  ),
                  TextField(
                    controller: newPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(labelText: 'Mật khẩu mới'),
                  ),
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Xác nhận mật khẩu mới',
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: Text('Huỷ'),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: Text('Xác nhận'),
                onPressed: () async {
                  final oldPassword = oldPasswordController.text;
                  final newPassword = newPasswordController.text;
                  final confirmPassword = confirmPasswordController.text;

                  if (newPassword != confirmPassword) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Mật khẩu mới không khớp')),
                    );
                    return;
                  }

                  try {
                    final user = FirebaseAuth.instance.currentUser!;
                    final email = user.email!;

                    final credential = EmailAuthProvider.credential(
                      email: email,
                      password: oldPassword,
                    );

                    // Xác thực lại
                    await user.reauthenticateWithCredential(credential);

                    // Đổi mật khẩu
                    await user.updatePassword(newPassword);

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Đổi mật khẩu thành công')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lỗi: ${e.toString()}')),
                    );
                  }
                },
              ),
            ],
          ),
    );
  }

  void _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text('Xác nhận'),
            content: Text('Bạn có chắc chắn muốn đăng xuất không?'),
            actions: [
              TextButton(
                child: Text('Huỷ'),
                onPressed: () => Navigator.pop(context, false),
              ),
              TextButton(
                child: Text('Đăng xuất'),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
    );

    if (shouldLogout == true) {
      await FirebaseAuth.instance.signOut();

      // Nếu bạn có lưu uid trong SharedPrefs thì nên xóa luôn
      SharedPrefsController.getInstance().clear();

      // Điều hướng về màn hình đăng nhập (thay bằng route bạn dùng)
      if (mounted) {
        AppNavigator.pushAndRemove(context, LoginScreen());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading || user == null
        ? Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: const Text('Profile'),
          ),
          body: Center(
            child:
                isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Không thể tải dữ liệu người dùng'),
          ),
        )
        : Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: const Text('Profile'),
          ),
          bottomNavigationBar: CustomBottomNavBar(
            currentIndex: 2,
            uid: user!.id,
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GapsManager.h20,
                CircleAvatar(
                  radius: RadiusSizes.r50,
                  child: Text(user!.name![0].toUpperCase()),
                ),
                GapsManager.h16,
                Text(user!.email, style: TextStyle(fontSize: TextSizes.s20)),
                GapsManager.h16,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _changePasswordDialog,
                      icon: Icon(Icons.lock_outline),
                      label: Text('Đổi mật khẩu'),
                    ),
                    ElevatedButton.icon(
                      onPressed: _logout,
                      icon: Icon(Icons.logout),
                      label: Text('Đăng xuất'),
                    ),
                  ],
                ),
                GapsManager.h16,
                Card(
                  elevation: 4,
                  margin: EdgeInsets.all(PaddingSizes.p16),
                  child: Padding(
                    padding: EdgeInsets.all(PaddingSizes.p16),
                    child: Column(
                      children: [
                        _buildInfoRow('Họ tên', user!.name!, 'name'),
                        DividerManager.horizontalDivider,
                        _buildInfoRow(
                          'Chiều cao (cm)',
                          '${user!.height}',
                          'height',
                        ),
                        DividerManager.horizontalDivider,
                        _buildInfoRow(
                          'Cân nặng (kg)',
                          '${user!.weight}',
                          'weight',
                        ),
                        DividerManager.horizontalDivider,
                        _buildInfoRow('Tuổi', '${user!.age}', 'age'),
                        DividerManager.horizontalDivider,
                        _buildInfoRow(
                          'Giới tính',
                          user!.gender! ? 'Nam' : 'Nữ',
                          'gender',
                          currentValue: user!.gender,
                        ),
                        DividerManager.horizontalDivider,
                        _buildInfoRow(
                          'Cân nặng mong muốn',
                          '${user!.weightGoal}',
                          'weightGoal',
                        ),
                        DividerManager.horizontalDivider,
                        _buildInfoRow(
                          'Mức độ vận động',
                          _activityFactors[user!.levelExercise] ??
                              '${user!.levelExercise}',
                          'levelExercise',
                          currentValue: user!.levelExercise,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Thống kê Calories trong tuần',
                  style: TextStyle(
                    fontSize: TextSizes.s18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CalorieStatsChart(
                    caloriesData: [1800, 2200, 2100, 2500, 1900, 2000, 2300],
                    dailyGoal: user!.dailyCaloriesGoal ?? 2000,
                  ),
                ),
              ],
            ),
          ),
        );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    String fieldKey, {
    dynamic currentValue,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            '$label: $value',
            style: TextStyle(fontSize: TextSizes.s16),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.edit, size: 20),
          onPressed:
              () => _editField(
                title: label,
                field: fieldKey,
                currentValue: currentValue ?? value,
              ),
        ),
      ],
    );
  }
}
