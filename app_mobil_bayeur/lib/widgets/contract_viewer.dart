import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ContractViewer extends StatefulWidget {
  final String contractText;
  final Function(bool) onReadComplete;

  const ContractViewer({
    super.key,
    required this.contractText,
    required this.onReadComplete,
  });

  @override
  State<ContractViewer> createState() => _ContractViewerState();
}

class _ContractViewerState extends State<ContractViewer> {
  final ScrollController _scrollController = ScrollController();
  double _progress = 0.0;
  bool _isComplete = false;

  void _onScroll() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      
      setState(() {
        _progress = (currentScroll / maxScroll).clamp(0.0, 1.0);
        if (_progress > 0.95 && !_isComplete) {
          _isComplete = true;
          widget.onReadComplete(true);
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LinearProgressIndicator(
          value: _progress,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Lecture: ${(_progress * 100).toInt()}%",
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Text(
                  widget.contractText,
                  style: GoogleFonts.inter(fontSize: 14, height: 1.6, color: Colors.blueGrey[900]),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
