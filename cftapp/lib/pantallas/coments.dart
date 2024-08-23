import 'package:cftapp/modelos/coments.dart';
import 'package:flutter/material.dart';
import '../db/database_helper.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _commentController = TextEditingController();
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Comment> _comments = [];

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    List<Comment> comments = await _databaseHelper.getComments();
    setState(() {
      _comments = comments;
    });
  }

  void _addComment() async {
    if (_commentController.text.isNotEmpty) {
      Comment newComment = Comment(content: _commentController.text);
      int id = await _databaseHelper.insertComment(newComment);
      if (id != -1) {
        _loadComments();
        _commentController.clear();
      }
    }
  }

  void _deleteComment(int id) async {
    await _databaseHelper.deleteComment(id);
    _loadComments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                labelText: 'Ingrese su comentario',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _addComment,
            child: Text('Agregar comentario'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _comments.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 3,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ListTile(
                    title: Text(_comments[index].content),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _deleteComment(_comments[index].id?? -1);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
