import 'package:flutter/material.dart';
import 'dart:async';
import 'package:teste/screens/history_screen.dart';
import 'package:teste/api/service.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final GithubService _githubService = GithubService();
  bool _loading = false;
  List<Map<String, dynamic>> _userDataList = [];
  List<String> _searchHistory = [];
  Timer? _debounce;

  Future<void> _searchUser(String username) async {
    if (username.isEmpty) {
      return;
    }

    setState(() {
      _loading = true;
      _userDataList = [];
    });

    try {
      final results = await _githubService.searchUsers(username);
      setState(() {
        _userDataList = results;
        _loading = false;
        if (!_searchHistory.contains(username)) {
          _searchHistory.add(username);
        }
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _userDataList = [];
      });
    }
  }


  void _onSearchChanged(String username) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchUser(username);
    });
  }

  void _navigateToHistory() async {
    final selectedUsername = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HistoryScreen(history: _searchHistory),
      ),
    );

    if (selectedUsername != null) {
      _controller.text = selectedUsername;
      _searchUser(selectedUsername);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: _navigateToHistory,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Image.network(
              'https://icones.pro/wp-content/uploads/2021/06/icone-github-grise.png',
              height: 100,
            ),
            Padding(padding: EdgeInsets.all(20.0)),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Insira o username',
                border: OutlineInputBorder(),
              ),
              onChanged: _onSearchChanged,
            ),
            SizedBox(height: 20),
            _loading
                ? CircularProgressIndicator()
                : _userDataList.isNotEmpty
                    ? Expanded(
                        child: ListView.builder(
                          itemCount: _userDataList.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(_userDataList[index]['login']),
                              subtitle: Text(_userDataList[index]['html_url']),
                              leading: Image.network(
                                  _userDataList[index]['avatar_url']),
                            );
                          },
                        ),
                      )
                    : Text('Sem resultados'),
          ],
        ),
      ),
    );
  }
}
