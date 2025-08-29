import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'bhavam_model.dart';
import 'bhavam_service.dart';

class BhavamController extends GetxController {
  RxList<BhavamModel> sins = <BhavamModel>[].obs;
  RxString description = ''.obs;
  String? bearerToken;

  final selectedSin = 1.obs; // Default sinId
  final TextEditingController noteController = TextEditingController();

  final List<Map<String, dynamic>> sinList = [
    {'id': 1, 'name': 'முதல் பாவம்'},
    {'id': 2, 'name': 'இரண்டாம் பாவம்'},
    {'id': 3, 'name': 'மூன்றாம் பாவம்'},
    {'id': 4, 'name': 'நான்காம் பாவம்'},
    {'id': 5, 'name': 'ஐந்தாம் பாவம்'},
    {'id': 6, 'name': 'ஆறாம் பாவம்'},
    {'id': 7, 'name': 'ஏழாம் பாவம்'},
    {'id': 8, 'name': 'எட்டாம் பாவம்'},
    {'id': 9, 'name': 'ஒன்பதாம் பாவம்'},
    {'id': 10, 'name': 'பத்தாம் பாவம்'},
    {'id': 11, 'name': 'பதினொன்றாம் பாவம்'},
    {'id': 12, 'name': 'பன்னிரண்டாம் பாவம்'},
  ];

  void initData(String token) {
    if (bearerToken != null) return;
    bearerToken = token;
    fetchSins();
  }

  Future<void> fetchSins() async {
    if (bearerToken == null) return;
    try {
      final data = await BhavamService.fetchSinsBySinId(
        bearerToken!,
        selectedSin.value,
      );
      sins.assignAll(data);
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch sins: $e');
    }
  }

  Future<void> addSin() async {
    if (bearerToken == null) return;
    final desc = noteController.text.trim();
    if (desc.isEmpty) return;
    try {
      await BhavamService.createSin(bearerToken!, selectedSin.value, desc);
      noteController.clear();
      await fetchSins();
      Get.snackbar('Success', 'Sin added successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add sin: $e');
    }
  }

  Future<void> updateSin(int postId, String newDesc) async {
    if (bearerToken == null) return;
    try {
      await BhavamService.updateSin(bearerToken!, postId, newDesc);
      await fetchSins();
      Get.snackbar('Success', 'Sin updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update sin: $e');
    }
  }

  Future<void> deleteSin(int postId) async {
    if (bearerToken == null) return;
    try {
      await BhavamService.deleteSin(bearerToken!, postId);
      await fetchSins();
      Get.snackbar('Success', 'Sin deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete sin: $e');
    }
  }
}
