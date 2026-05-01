import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:app_mobil_bayeur/services/payment_service.dart';
import 'package:app_mobil_bayeur/services/api_service.dart';
import 'package:intl/intl.dart';

class RentCalendarScreen extends ConsumerStatefulWidget {
  final String? leaseId;

  const RentCalendarScreen({super.key, this.leaseId});

  @override
  ConsumerState<RentCalendarScreen> createState() => _RentCalendarScreenState();
}

class _RentCalendarScreenState extends ConsumerState<RentCalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Map<String, dynamic>>> _events = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    try {
      final paymentService = PaymentService(ApiService());
      final eventsList = await paymentService.getPaymentCalendar(_focusedDay.year, _focusedDay.month);
      
      final Map<DateTime, List<Map<String, dynamic>>> newEvents = {};
      for (var event in eventsList) {
        final date = DateTime.parse(event['due_date']);
        final day = DateTime(date.year, date.month, date.day);
        if (newEvents[day] == null) newEvents[day] = [];
        newEvents[day]!.add(event);
      }

      setState(() {
        _events = newEvents;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Erreur chargement calendrier: $e");
    }
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Calendrier des loyers", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.now().subtract(const Duration(days: 365)),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() => _calendarFormat = format);
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
              _loadEvents();
            },
            eventLoader: _getEventsForDay,
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(color: Colors.blue[200], shape: BoxShape.circle),
              selectedDecoration: BoxDecoration(color: Colors.blue[900], shape: BoxShape.circle),
              markerDecoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
            ),
            headerStyle: HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
              titleTextStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildEventList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEventList() {
    final selectedEvents = _getEventsForDay(_selectedDay ?? _focusedDay);
    if (selectedEvents.isEmpty) {
      return Center(
        child: Text(
          "Aucun paiement prévu pour ce jour",
          style: TextStyle(color: Colors.grey[500]),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: selectedEvents.length,
      itemBuilder: (context, index) {
        final event = selectedEvents[index];
        final isPaid = event['status'] == 'PAID';
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          child: ListTile(
            leading: Icon(
              isPaid ? Icons.check_circle : Icons.error_outline,
              color: isPaid ? Colors.green : Colors.orange,
              size: 32,
            ),
            title: Text(
              event['property_name'] ?? "Loyer Mensuel",
              style: GoogleFonts.inter(fontWeight: FontWeight.bold),
            ),
            subtitle: Text("Montant: ${event['amount']} FCFA"),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  isPaid ? "PAYÉ" : "À VENIR",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isPaid ? Colors.green : Colors.orange,
                    fontSize: 10,
                  ),
                ),
                Text(
                  DateFormat('dd MMM').format(DateTime.parse(event['due_date'])),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
