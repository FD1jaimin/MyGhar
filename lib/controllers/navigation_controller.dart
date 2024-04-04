
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:get/get.dart';
class NavigationController extends GetxController {
  var currentIndex = 0.obs;
  late AdvancedDrawerController advancedDrawerController;

  @override
  void onInit() {
    super.onInit();
    advancedDrawerController = AdvancedDrawerController();
  }

  onPageChange(index) {
    currentIndex.value = index;
  }
}