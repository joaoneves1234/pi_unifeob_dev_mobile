import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'meetings_details_screen.dart';

class MeetingsListScreen extends StatelessWidget {
  Stream<QuerySnapshot> _getMeetings() {
    return FirebaseFirestore.instance
        .collection('meetings')
        .orderBy('date')
        .snapshots();
  }

  Future<void> _joinMeeting(BuildContext context, String meetingId) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    try {
      await FirebaseFirestore.instance.collection('meetings').doc(meetingId).update({
        'participants': FieldValue.arrayUnion([userId]),
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Você entrou na reunião!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao participar da reunião: $e')));
    }
  }

  String _formatDate(DateTime date) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');
    return formatter.format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Colors.blueGrey.shade900, // Cor do AppBar igual a da tela inicial
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white), // Botão de voltar
          onPressed: () => Navigator.pop(context),
          tooltip: 'Voltar',
          iconSize: 30,
        ),
        title: Text('Reuniões Agendadas', style: TextStyle(color: Colors.white)),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueGrey.shade900, Colors.blueGrey.shade700], // Gradiente igual a tela inicial
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: _getMeetings(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Erro ao carregar reuniões'));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('Nenhuma reunião agendada'));
            }

            final meetings = snapshot.data!.docs;

            return ListView.builder(
              itemCount: meetings.length,
              itemBuilder: (ctx, index) {
                final meeting = meetings[index];
                final meetingId = meeting.id;
                final participants = List<String>.from(meeting['participants']);

                final userId = FirebaseAuth.instance.currentUser!.uid;
                final isUserParticipating = participants.contains(userId);

                final formattedDate = _formatDate(meeting['date'].toDate());

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                  child: ListTile(
                    title: Text(meeting['title']),
                    subtitle: Text(meeting['description']),
                    trailing: Text(formattedDate),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MeetingDetailsScreen(meetingId: meetingId),
                        ),
                      );
                    },
                    contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                    isThreeLine: true,
                    leading: ElevatedButton(
                      onPressed: isUserParticipating
                          ? null
                          : () {
                              _joinMeeting(context, meetingId);
                            },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        textStyle: TextStyle(fontSize: 16),
                        backgroundColor: isUserParticipating ? Colors.grey : Colors.blueAccent, // Alterando cor do botão
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 5,
                      ),
                      child: Text(isUserParticipating ? 'Você já está' : 'Participar'),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
