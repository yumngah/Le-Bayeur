import 'package:app_mobil_bayeur/models/comment_model.dart';
import 'package:app_mobil_bayeur/services/api_service.dart';

class CommentService {
  final ApiService _api;

  CommentService(this._api);

  Future<List<Comment>> getPropertyComments(String propertyId, {int limit = 20, int offset = 0}) async {
    final response = await _api.get('/comments/property/$propertyId', params: {
      'limit': limit,
      'offset': offset,
    });
    return (response.data as List).map((json) => Comment.fromJson(json)).toList();
  }

  Future<Comment> postComment(String propertyId, String content, {int? rating, String? parentId}) async {
    final response = await _api.post('/comments', data: {
      'property_id': propertyId,
      'content': content,
      'rating': rating,
      'parent_id': parentId,
    });
    return Comment.fromJson(response.data);
  }

  Future<void> interactWithComment(String commentId, String type) async {
    await _api.post('/comments/$commentId/interact', data: {'type': type});
  }

  Future<void> reportComment(String commentId) async {
    await _api.post('/comments/$commentId/report');
  }

  Future<void> deleteComment(String commentId) async {
    await _api.delete('/comments/$commentId');
  }
}
