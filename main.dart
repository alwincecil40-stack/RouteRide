import 'package:flutter/material.dart';

void main() => runApp(const RouteRideApp());

class RouteRideApp extends StatelessWidget {
  const RouteRideApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'RouteRide',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0B6B57)),
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF4F7F6),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
      ),
    ),
    home: const TripPlannerPage(),
  );
}

class TripPlannerPage extends StatefulWidget {
  const TripPlannerPage({super.key});
  @override
  State<TripPlannerPage> createState() => _TripPlannerPageState();
}

class _TripPlannerPageState extends State<TripPlannerPage> {
  final pickup = TextEditingController(text: 'Bangalore Airport');
  final drop = TextEditingController(text: 'Calicut Airport');
  final date = TextEditingController();
  final List<TextEditingController> destinations = [
    TextEditingController(text: 'Mysore Palace'),
    TextEditingController(text: 'Madikeri'),
    TextEditingController(text: 'Ooty'),
  ];
  String vehicle = 'Maruti Suzuki Ertiga AC — 6+1 Seater';
  int passengers = 6;

  double get km => 180 + destinations.where((d) => d.text.trim().isNotEmpty).length * 95 +
      (pickup.text.toLowerCase().contains('bangalore') ? 70 : 0) +
      (drop.text.toLowerCase().contains('calicut') ? 55 : 0);

  int get fuel => (km / (vehicle.startsWith('Maruti') ? 12 : vehicle.startsWith('Toyota') ? 10 : 7) * 100).round();
  int get toll => (900 + km * .9).round();
  int get total => ((vehicle.startsWith('Maruti') ? 1500 : vehicle.startsWith('Toyota') ? 1800 : 2500) + fuel + toll + km * (vehicle.startsWith('Maruti') ? 1.8 : 2.4)).round();

  @override
  void initState() {
    super.initState();
    date.text = DateTime.now().toIso8601String().substring(0, 10);
  }

  @override
  void dispose() {
    pickup.dispose(); drop.dispose(); date.dispose(); drop.dispose();
    for (final d in destinations) d.dispose();
    super.dispose();
  }

  void recalc() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final stops = [pickup.text, ...destinations.map((e) => e.text).where((e) => e.trim().isNotEmpty), drop.text];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF075643),
        foregroundColor: Colors.white,
        title: const Text('🚕 RouteRide', style: TextStyle(fontWeight: FontWeight.w800)),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(42),
          child: Padding(
            padding: EdgeInsets.only(left: 16, right: 16, bottom: 18),
            child: Align(alignment: Alignment.centerLeft, child: Text('Taxi & Tour Planner', style: TextStyle(color: Colors.white70))),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: FilledButton(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Quotation request prepared successfully.')),
            ),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF0B6B57), padding: const EdgeInsets.all(16)),
            child: const Text('REQUEST QUOTATION', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Plan your journey your way.', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          const Text('Add every destination you want to visit and request a custom taxi quotation.'),
          const SizedBox(height: 18),
          _card('1. Trip details', [
            _field('Pickup location', pickup),
            Row(children: [
              Expanded(child: _field('Travel date', date)),
              const SizedBox(width: 10),
              Expanded(child: DropdownButtonFormField<int>(
                value: passengers,
                decoration: const InputDecoration(labelText: 'Passengers'),
                items: List.generate(7, (i) => i + 1).map((n) => DropdownMenuItem(value: n, child: Text('$n'))).toList(),
                onChanged: (v) => setState(() => passengers = v ?? 6),
              )),
            ]),
            _field('Drop-off location', drop),
          ]),
          _card('2. Add your destinations', [
            for (int i = 0; i < destinations.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: Row(children: [
                  CircleAvatar(radius: 15, child: Text('${i + 1}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                  const SizedBox(width: 8),
                  Expanded(child: TextField(controller: destinations[i], onChanged: (_) => recalc(), decoration: const InputDecoration(hintText: 'Search destination...'))),
                  IconButton(onPressed: destinations.length > 1 ? () { setState(() { destinations[i].dispose(); destinations.removeAt(i); }); } : null, icon: const Icon(Icons.close)),
                ]),
              ),
            OutlinedButton.icon(
              onPressed: () => setState(() => destinations.add(TextEditingController())),
              icon: const Icon(Icons.add),
              label: const Text('Add destination'),
            ),
            const SizedBox(height: 6),
            const Text('You can add as many places as you want. The final route can be reviewed before confirmation.', style: TextStyle(fontSize: 11, color: Colors.grey)),
          ]),
          _card('3. Vehicle', [
            DropdownButtonFormField<String>(
              value: vehicle,
              decoration: const InputDecoration(labelText: 'Choose vehicle'),
              items: const [
                DropdownMenuItem(value: 'Maruti Suzuki Ertiga AC — 6+1 Seater', child: Text('Maruti Suzuki Ertiga AC — 6+1 Seater')),
                DropdownMenuItem(value: 'Toyota Innova — 6+1 Seater', child: Text('Toyota Innova — 6+1 Seater')),
                DropdownMenuItem(value: 'Tempo Traveller — 12 Seater', child: Text('Tempo Traveller — 12 Seater')),
              ],
              onChanged: (v) => setState(() => vehicle = v!),
            ),
          ]),
          _card('Trip estimate', [
            Row(children: [
              Expanded(child: _metric('Estimated distance', '${km.round()} km')),
              const SizedBox(width: 10),
              Expanded(child: _metric('Estimated driving', '${(km / 42).toStringAsFixed(1)} hrs')),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _metric('Fuel estimate', '₹${fuel.toString()}')),
              const SizedBox(width: 10),
              Expanded(child: _metric('Toll / misc.', '₹$toll')),
            ]),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFF102F29), borderRadius: BorderRadius.circular(15)),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Estimated trip fare', style: TextStyle(color: Colors.white70)),
                  SizedBox(height: 4),
                  Text('Final quotation confirmed by operator', style: TextStyle(color: Colors.white54, fontSize: 11)),
                ]),
                Text('₹$total', style: const TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.bold)),
              ]),
            ),
          ]),
          _card('Route preview', [
            for (int i = 0; i < stops.length; i++)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(i == 0 ? Icons.trip_origin : i == stops.length - 1 ? Icons.location_on : Icons.circle, color: const Color(0xFF0B6B57)),
                title: Text(i == 0 ? 'Pickup' : i == stops.length - 1 ? 'Drop-off' : 'Destination $i', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                subtitle: Text(stops[i]),
              ),
          ]),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _card(String title, List<Widget> children) => Card(
    margin: const EdgeInsets.only(bottom: 14),
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: const BorderSide(color: Color(0xFFDFE8E5))),
    child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
      const SizedBox(height: 14),
      ...children.map((w) => Padding(padding: const EdgeInsets.only(bottom: 12), child: w)),
    ])),
  );

  Widget _field(String label, TextEditingController c) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(controller: c, onChanged: (_) => recalc(), decoration: InputDecoration(labelText: label)),
  );

  Widget _metric(String label, String value) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: const Color(0xFFF7FAF9), borderRadius: BorderRadius.circular(12)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      const SizedBox(height: 4),
      Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    ]),
  );
}
