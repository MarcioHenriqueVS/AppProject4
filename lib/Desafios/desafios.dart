import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db_firestore.dart';
import 'Desafios_Services.dart';

class Desafios extends StatefulWidget {
  final String desafioNome;
  Desafios({required this.desafioNome});

  @override
  State<Desafios> createState() => _DesafiosState();
}

class _DesafiosState extends State<Desafios> {
  String? autor;
  String? _uid;
  late List<DateTime> _weekDays;
  late Map<String, dynamic> _documentData = {};
  late DateTime _today;
  bool _isLoading = true;
  final fetchDoc _fetchDoc = fetchDoc();
  final DateTimeService _dateTimeService = DateTimeService();

  @override
  void initState() {
    super.initState();
    _fetchDoc.getCurrentUser((String? uid, String? displayName) {
      setState(() {
        _uid = uid;
        autor = displayName;
      });
    });
    _weekDays = _dateTimeService.getWeekDays();
    _fetchDocumentData();
    _today = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now()/*.subtract(Duration(days: 1))*/;
    return _isLoading
        ? const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    )
        : Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text(widget.desafioNome),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: const [
                Text(''),
              ],
            ),
          ),
          floatingActionButton: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              7,
                  (index) {
                final date = _weekDays[index].toLocal();
                final idString = DateFormat('yyyy-MM-dd').format(date);
                final hasDocument = _documentData.containsKey(idString);
                final isBefore =
                    date.add(Duration(days: 1)).isBefore(today) &&
                        !hasDocument;
                final isEnabled =
                    date.add(Duration(days: 1)).isBefore(today) &&
                        date.isAfter(today);
                final backgroundColor =
                _documentData.containsKey(idString)
                    ? Colors.green
                    : isBefore
                    ? Colors.red
                    : Colors.grey;
                return FloatingActionButton(
                  heroTag: idString,
                  onPressed: !isEnabled && !hasDocument ? () {} : null,
                  tooltip: idString,
                  backgroundColor: backgroundColor,
                  child: Text(
                    DateFormat.E('pt_BR').format(date),
                  ),
                );
              },
            ),
          ),
        ),
        Positioned(
          top: 100,
          right: 20,
          child: FloatingActionButton(
            onPressed: () async {
              var nomeDoDesafio = widget.desafioNome;
              await Fireservices.addData(nomeDoDesafio, autor);
              await _fetchDocumentData();
              await Fireservices.addPonto();
              Fireservices.addFeed();
            },
            child: Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  Future<void> _fetchDocumentData() async {
    var nomeDoDesafio = widget.desafioNome;
    await _fetchDoc.fetchDocumentData(nomeDoDesafio, _uid!, (Map<String, dynamic> data) {
      setState(() {
        _documentData = data;
      });
    });
    setState(() {
      _isLoading = false;
    });
  }
}