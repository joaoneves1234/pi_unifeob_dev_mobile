import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MeetingCreateScreen extends StatefulWidget {
  @override
  _MeetingCreateScreenState createState() => _MeetingCreateScreenState();
}

class _MeetingCreateScreenState extends State<MeetingCreateScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedDate;

  Future<void> _saveMeeting() async {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Todos os campos são obrigatórios!')));
      return;
    }

    if (_selectedDate!.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Não é possível agendar uma reunião no passado!')));
      return;
    }

    final userId = FirebaseAuth.instance.currentUser!.uid;

    try {
      final timestamp = Timestamp.fromDate(_selectedDate!);

      await FirebaseFirestore.instance.collection('meetings').add({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'date': timestamp,
        'participants': [userId],
        'creatorId': userId,
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Reunião agendada com sucesso!')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao agendar reunião: $e')));
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Colors.blueGrey.shade900, // Mantendo a cor azul escuro
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white), // Botão de voltar
          onPressed: () => Navigator.pop(context),
          tooltip: 'Voltar',
          iconSize: 30,
        ),
        title: Text('Agendar Reunião', style: TextStyle(color: Colors.white)),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueGrey.shade900, Colors.blueGrey.shade700], // Usando o mesmo gradiente da HomeScreen
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8), // Fundo semi-transparente para os campos
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'Título',
                          labelStyle: TextStyle(color: Colors.blueGrey.shade900),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Descrição',
                          labelStyle: TextStyle(color: Colors.blueGrey.shade900),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextButton(
                        onPressed: _selectDate,
                        child: Text(
                          _selectedDate == null
                              ? 'Selecionar Data'
                              : 'Data: ${_selectedDate!.toLocal()}',
                          style: TextStyle(color: Colors.blueAccent),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextButton(
                        onPressed: _selectTime,
                        child: Text(
                          _selectedDate == null
                              ? 'Selecionar Hora'
                              : 'Hora: ${_selectedDate!.hour}:${_selectedDate!.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(color: Colors.blueAccent),
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _saveMeeting,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          textStyle: TextStyle(fontSize: 18),
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 5,
                        ),
                        child: Text(
                          'Salvar Reunião',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
