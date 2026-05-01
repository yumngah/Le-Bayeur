import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:app_mobil_bayeur/models/maintenance_model.dart';
import 'package:app_mobil_bayeur/services/maintenance_service.dart';
import 'package:app_mobil_bayeur/services/api_service.dart';


class MaintenancePlanningScreen extends ConsumerStatefulWidget {
  final String propertyId;

  const MaintenancePlanningScreen({super.key, required this.propertyId});

  @override
  ConsumerState<MaintenancePlanningScreen> createState() => _MaintenancePlanningScreenState();
}

class _MaintenancePlanningScreenState extends ConsumerState<MaintenancePlanningScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late MaintenanceService _maintenanceService;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<MaintenanceRequest>> _events = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _maintenanceService = MaintenanceService(ApiService());
    _selectedDay = _focusedDay;
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final requests = await _maintenanceService.getPropertyMaintenanceRequests(widget.propertyId);
    final Map<DateTime, List<MaintenanceRequest>> eventMap = {};
    for (var r in requests) {
      final date = DateTime(r.completedAt?.year ?? 2024, r.completedAt?.month ?? 1, r.completedAt?.day ?? 1); // Mock dates for now
      if (eventMap[date] == null) eventMap[date] = [];
      eventMap[date]!.add(r);
    }
    setState(() => _events = eventMap);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Gestion Maintenance", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue[900],
          indicatorColor: Colors.blue[900],
          tabs: [
            const Tab(text: "Calendrier"),
            const Tab(text: "Listes"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCalendarTab(),
          _buildRequestsTab(),
        ],
      ),
    );
  }

  Widget _buildCalendarTab() {
    return Column(
      children: [
        TableCalendar<MaintenanceRequest>(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          eventLoader: (day) => _events[DateTime(day.year, day.month, day.day)] ?? [],
          calendarStyle: CalendarStyle(
            markerDecoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
            todayDecoration: BoxDecoration(color: Colors.blue[100], shape: BoxShape.circle),
            selectedDecoration: BoxDecoration(color: Colors.blue[900], shape: BoxShape.circle),
          ),
          onFormatChanged: (format) => setState(() => _calendarFormat = format),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _buildEventList(),
        ),
      ],
    );
  }

  Widget _buildEventList() {
    final selectedEvents = _events[DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day)] ?? [];
    if (selectedEvents.isEmpty) {
      return const Center(child: Text("Aucune maintenance ce jour"));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: selectedEvents.length,
      itemBuilder: (context, index) {
        final event = selectedEvents[index];
        final color = event.type == MaintenanceType.ELECTRICITY ? Colors.red : Colors.blue;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
                child: Icon(_getTypeIcon(event.type), color: Colors.white, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(event.description, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text("Technicien: Assigné", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRequestsTab() {
    return FutureBuilder<List<MaintenanceRequest>>(
      future: _maintenanceService.getPropertyMaintenanceRequests(widget.propertyId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("Aucun historique"));
        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) => _buildRequestItem(snapshot.data![index]),
        );
      },
    );
  }

  Widget _buildRequestItem(MaintenanceRequest req) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: _getUrgencyColor(req.urgency).withValues(alpha: 0.1),
        child: Icon(_getTypeIcon(req.type), color: _getUrgencyColor(req.urgency), size: 20),
      ),
      title: Text(req.description, maxLines: 1),
      subtitle: Text(req.status.name, style: TextStyle(fontSize: 12, color: _getStatusColor(req.status))),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
    );
  }

  Color _getUrgencyColor(Urgency urgency) => urgency == Urgency.URGENT ? Colors.red : Colors.orange;
  Color _getStatusColor(RequestStatus status) => status == RequestStatus.COMPLETED ? Colors.green : Colors.blue;
  IconData _getTypeIcon(MaintenanceType type) {
    switch (type) {
      case MaintenanceType.ELECTRICITY: return Icons.electric_bolt;
      case MaintenanceType.PLUMBING: return Icons.water_drop;
      default: return Icons.home_repair_service;
    }
  }
}
