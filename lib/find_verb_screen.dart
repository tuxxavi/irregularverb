import 'package:flutter/material.dart';
import 'package:irregular_verbs/global.dart'; // Asegúrate que VERBS esté definido como List<Map<String, String>>

class FindVerbScreen extends StatefulWidget {
  const FindVerbScreen({super.key});

  @override
  _FindVerbScreenState createState() => _FindVerbScreenState();
}

class _FindVerbScreenState extends State<FindVerbScreen> {
  final TextEditingController _presentController = TextEditingController();
  final TextEditingController _pastController = TextEditingController();
  final TextEditingController _perfectController = TextEditingController();
  final TextEditingController _spanishController = TextEditingController();

  List<Map<String, String>> filteredVerbs = [];

  @override
  void initState() {
    super.initState();
    filteredVerbs = VERBS; // Muestra todo al inicio
  }

  void filterVerbs() {
    final present = _presentController.text.toLowerCase();
    final past = _pastController.text.toLowerCase();
    final perfect = _perfectController.text.toLowerCase();
    final spanish = _spanishController.text.toLowerCase();

    setState(() {
      filteredVerbs = VERBS.where((verb) {
        bool matches = true;

        if (present.isNotEmpty) {
          matches &= verb['present']!.toLowerCase().contains(present);
        }
        if (past.isNotEmpty) {
          matches &= verb['past']!.toLowerCase().contains(past);
        }
        if (perfect.isNotEmpty) {
          matches &= verb['perfect']!.toLowerCase().contains(perfect);
        }
        if (spanish.isNotEmpty) {
          matches &= verb['spanish']!.toLowerCase().contains(spanish);
        }

        return matches;
      }).toList();
    });
  }

  Widget buildSearchField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      onChanged: (_) => filterVerbs(),
    );
  }

  @override
  void dispose() {
    _presentController.dispose();
    _pastController.dispose();
    _perfectController.dispose();
    _spanishController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Find Verb'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            buildSearchField('Present', _presentController),
            SizedBox(height: 10),
            buildSearchField('Past', _pastController),
            SizedBox(height: 10),
            buildSearchField('Perfect', _perfectController),
            SizedBox(height: 10),
            buildSearchField('Spanish', _spanishController),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: filteredVerbs.length,
                itemBuilder: (context, index) {
                  final verb = filteredVerbs[index];
                  return Card(
                    child: ListTile(
                      title: Text('${verb['present']} - ${verb['past']} - ${verb['perfect']}'),
                      subtitle: Text('Español: ${verb['spanish']}'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
