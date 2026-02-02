// lib/features/schedules/data/services/absence_api_service.dart
import 'package:dio/dio.dart';
import '../models/absence_dto.dart';
import '../../../../core/networking/dio_client.dart';
class AbsenceApiService {
   final Dio _dio = DioClient.instance.dio;


  //AbsenceApiService(this._dio);

 Future<List<AbsenceDto>> getMyAbsences() async {
  try {
    final response = await _dio.get('/api/absences');
    
    // بررسی اینکه آیا دیتا در فیلد 'data' است یا مستقیم در بدنه
    final dynamic rawData = response.data is Map ? response.data['data'] : response.data;
    
    if (rawData == null) return [];

    return (rawData as List)
        .map((json) => AbsenceDto.fromJson(json))
        .toList();
  } catch (e) {
    rethrow;
  }
}

  Future<bool> createAbsence(AbsenceDto dto) async {
    try {
      await _dio.post('/api/absences', data: dto.toJson());
      return true;
    } catch (e) {
      print('خطا در ثبت غیبت: $e');
      return false;
    }
  }

  Future<bool> updateAbsence(int id, AbsenceDto dto) async {
    try {
      await _dio.put('/api/absences/$id', data: dto.toJson());
      return true;
    } catch (e) {
      print('خطا در ویرایش غیبت: $e');
      return false;
    }
  }

  Future<bool> deleteAbsence(int id) async {
    try {
      await _dio.delete('/api/absences/$id');
      return true;
    } catch (e) {
      print('خطا در حذف غیبت: $e');
      return false;
    }
  }
}