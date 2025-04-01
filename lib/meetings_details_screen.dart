import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MeetingDetailsScreen extends StatefulWidget {
  final String meetingId;

  MeetingDetailsScreen({required this.meetingId});

  @override
  _MeetingDetailsScreenState createState() => _MeetingDetailsScreenState();
}

class _MeetingDetailsScreenState extends State<MeetingDetailsScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedDate;

  bool _isEditing = false;
  late DateTime _meetingDate;

  // Função para carregar os detalhes da reunião
  Future<void> _loadMeetingDetails() async {
    try {
      DocumentSnapshot meetingDoc = await FirebaseFirestore.instance
          .collection('meetings')
          .doc(widget.meetingId)
          .get();

      if (meetingDoc.exists) {
        _titleController.text = meetingDoc['title'];
        _descriptionController.text = meetingDoc['description'];
        _meetingDate = meetingDoc['date'].toDate();

        setState(() {
          _selectedDate = _meetingDate;
        });
      }
    } catch (e) {
      print('Erro ao carregar detalhes da reunião: $e');
    }
  }

  // Função para salvar os dados da reunião
  Future<void> _saveMeeting() async {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Todos os campos são obrigatórios!')));
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('meetings').doc(widget.meetingId).update({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'date': Timestamp.fromDate(_selectedDate!),
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Reunião atualizada com sucesso!')));
      setState(() {
        _isEditing = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao atualizar reunião: $e')));
    }
  }

  // Função para selecionar a data
  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate!,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          _selectedDate!.hour,
          _selectedDate!.minute,
        );
      });
    }
  }

  // Função para selecionar o horário
  Future<void> _selectTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDate!),
    );

    if (pickedTime != null) {
      setState(() {
        _selectedDate = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

  // Função para excluir a reunião
  Future<void> _deleteMeeting() async {
    try {
      await FirebaseFirestore.instance.collection('meetings').doc(widget.meetingId).delete();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Reunião excluída com sucesso!')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao excluir reunião: $e')));
    }
  }

  @override
  void initState() {
    super.initState();
    _loadMeetingDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes da Reunião', style: TextStyle(color: Colors.white)), // Título da AppBar com fonte branca
        backgroundColor: Colors.blueGrey.shade900,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueGrey.shade900, Colors.blueGrey.shade700], // Gradiente de fundo
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('meetings').doc(widget.meetingId).get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Erro ao carregar os detalhes da reunião.', style: TextStyle(color: Colors.white)));
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Center(child: Text('Reunião não encontrada.', style: TextStyle(color: Colors.white)));
            }

            final meeting = snapshot.data!;
            final participants = List<String>.from(meeting['participants']);
            final creatorId = meeting['creatorId'];

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isEditing)
                    Column(
                      children: [
                        TextField(
                          controller: _titleController,
                          decoration: InputDecoration(labelText: 'Título', labelStyle: TextStyle(color: Colors.white)), // Fontes claras nos campos
                          style: TextStyle(color: Colors.white), // Cor do texto
                        ),
                        TextField(
                          controller: _descriptionController,
                          decoration: InputDecoration(labelText: 'Descrição', labelStyle: TextStyle(color: Colors.white)), // Fontes claras nos campos
                          style: TextStyle(color: Colors.white), // Cor do texto
                        ),
                        SizedBox(height: 16),
                        TextButton(
                          onPressed: _selectDate,
                          child: Text(
                            'Data: ${_selectedDate == null ? 'Selecionar Data' : DateFormat('dd/MM/yyyy').format(_selectedDate!)}',
                            style: TextStyle(color: Colors.white), // Texto em branco
                          ),
                        ),
                        SizedBox(height: 16),
                        TextButton(
                          onPressed: _selectTime,
                          child: Text(
                            'Hora: ${_selectedDate == null ? 'Selecionar Hora' : DateFormat('HH:mm').format(_selectedDate!)}',
                            style: TextStyle(color: Colors.white), // Texto em branco
                          ),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _saveMeeting,
                          child: Text('Salvar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isEditing = false;
                            });
                          },
                          child: Text('Cancelar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                          ),
                        ),
                      ],
                    )
                  else ...[
                    Text('Título: ${meeting['title']}', style: TextStyle(color: Colors.white)), // Fonte clara para título
                    SizedBox(height: 8),
                    Text('Descrição: ${meeting['description']}', style: TextStyle(color: Colors.white)), // Fonte clara para descrição
                    SizedBox(height: 8),
                    Text('Data: ${DateFormat('dd/MM/yyyy HH:mm').format(_meetingDate)}', style: TextStyle(color: Colors.white)), // Fonte clara para data
                    SizedBox(height: 16),
                    if (FirebaseAuth.instance.currentUser!.uid == creatorId)
                      Column(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _isEditing = true;
                              });
                            },
                            child: Text('Editar Reunião'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: _deleteMeeting,
                            child: Text('Excluir Reunião'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                  ],
                  SizedBox(height: 16),
                  Text('Participantes:', style: TextStyle(color: Colors.white)), // Fonte clara para participantes
                  Expanded(
                    child: FutureBuilder<List<String>>(
                      future: _getParticipantsNames(participants),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }

                        if (snapshot.hasError || !snapshot.hasData) {
                          return Center(child: Text('Erro ao carregar participantes.', style: TextStyle(color: Colors.white)));
                        }

                        final participantsNames = snapshot.data!;

                        return ListView.builder(
                          itemCount: participantsNames.length,
                          itemBuilder: (context, index) {
                            final participantName = participantsNames[index];
                            final isCurrentUser = participantName == "Você";

                            return ListTile(
                              title: Text(
                                participantName,
                                style: TextStyle(
                                  color: isCurrentUser ? Colors.green : Colors.blue,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<List<String>> _getParticipantsNames(List<String> participants) async {
    List<String> participantsNames = [];

    for (var participantId in participants) {
      String participantName = await _getUserName(participantId);

      if (participantId == FirebaseAuth.instance.currentUser!.uid) {
        participantsNames.add("Você");
      } else {
        participantsNames.add(participantName);
      }
    }

    return participantsNames;
  }

  Future<String> _getUserName(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return userDoc['displayName'] ?? 'Desconhecido';
      } else {
        return 'Desconhecido';
      }
    } catch (e) {
      return 'Desconhecido';
    }
  }
}
