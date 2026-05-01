import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_mobil_bayeur/models/comment_model.dart';
import 'package:app_mobil_bayeur/services/comment_service.dart';
import 'package:app_mobil_bayeur/services/api_service.dart';

class CommentsScreen extends StatefulWidget {
  final String propertyId;

  const CommentsScreen({super.key, required this.propertyId});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final _commentController = TextEditingController();
  late CommentService _commentService;
  List<Comment> _comments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _commentService = CommentService(ApiService());
    _loadComments();
  }

  Future<void> _loadComments() async {
    try {
      final cs = await _commentService.getPropertyComments(widget.propertyId);
      setState(() {
        _comments = cs;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Erreur chargement commentaires: $e");
    }
  }

  void _postComment() async {
    if (_commentController.text.trim().isEmpty) return;
    
    try {
      await _commentService.postComment(widget.propertyId, _commentController.text);
      _commentController.clear();
      _loadComments();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Commentaires", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _comments.length,
                  itemBuilder: (context, index) => _buildCommentItem(_comments[index]),
                ),
          ),
          _buildCommentInput(),
        ],
      ),
    );
  }

  Widget _buildCommentItem(Comment comment) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey[200],
            child: const Icon(Icons.person, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(comment.username, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(width: 8),
                    Text(comment.createdAt.toString(), style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(comment.content, style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    InkWell(onTap: () {}, child: const Icon(Icons.thumb_up_alt_outlined, size: 16, color: Colors.grey)),
                    const SizedBox(width: 4),
                    Text(comment.likes.toString(), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(width: 16),
                    InkWell(onTap: () {}, child: const Icon(Icons.reply, size: 16, color: Colors.grey)),
                    const Text(" Répondre", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey[200]!))),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: "Ajouter un commentaire...",
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _postComment,
            icon: Icon(Icons.send, color: Colors.blue[900]),
          ),
        ],
      ),
    );
  }
}
