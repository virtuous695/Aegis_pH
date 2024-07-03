import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  Future<void> saveParameter(
      Map<String, dynamic> parameterInfoMap, String deviceId) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Check if the device ID exists in the parameterInfoMap
      if (!parameterInfoMap.containsKey('device_id')) {
        // Add device ID to the map if not already present
        parameterInfoMap['device_id'] = deviceId;
      }

      // Set the document with the provided device ID in the 'Parameter' collection
      await firestore
          .collection("Parameter")
          .doc(deviceId)
          .set(parameterInfoMap);
    } catch (e) {
      throw Exception('Error saving parameter: $e');
    }
  }

  Future<Stream<QuerySnapshot>> getParametersByDeviceId(String deviceId) async {
    return FirebaseFirestore.instance
        .collection("Parameter")
        .where('device_id', isEqualTo: deviceId)
        .snapshots();
  }
}
