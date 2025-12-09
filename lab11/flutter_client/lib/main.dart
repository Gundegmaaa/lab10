import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Person CRUD App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PersonListScreen(),
    );
  }
}

class Person {
  final int id;
  final String name;
  final int? born;

  Person({
    required this.id,
    required this.name,
    this.born,
  });

  factory Person.fromJson(Map<String, dynamic> json) {
    try {
      // Handle different possible types for id (int, num, etc.)
      int id;
      if (json['id'] is int) {
        id = json['id'] as int;
      } else if (json['id'] is num) {
        id = (json['id'] as num).toInt();
      } else {
        id = int.parse(json['id'].toString());
      }
      
      // Handle name
      String name = json['name']?.toString() ?? '';
      
      // Handle born (can be null, int, or num)
      int? born;
      if (json['born'] != null) {
        if (json['born'] is int) {
          born = json['born'] as int;
        } else if (json['born'] is num) {
          born = (json['born'] as num).toInt();
        } else {
          born = int.tryParse(json['born'].toString());
        }
      }
      
      return Person(
        id: id,
        name: name,
        born: born,
      );
    } catch (e) {
      print('Person.fromJson error: $e, JSON: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'born': born,
    };
  }
}

class PersonService {
  // For Android emulator use: http://10.0.2.2:8000/api/persons/
  // For physical device use your computer's IP: http://192.168.x.x:8000/api/persons/
  static const String baseUrl = 'http://127.0.0.1:8000/api/persons/';

  static Future<List<Person>> getPersons() async {
    try {
      final response = await http.get(Uri.parse(baseUrl)).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Connection timeout. Make sure Django API is running.');
        },
      );
      
      print('GET Response Status: ${response.statusCode}');
      print('GET Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          return [];
        }
        
        try {
          final decoded = json.decode(response.body);
          print('Decoded response: $decoded');
          
          if (decoded is List) {
            return decoded.map((json) {
              try {
                return Person.fromJson(json as Map<String, dynamic>);
              } catch (e) {
                print('Error parsing person: $json, Error: $e');
                rethrow;
              }
            }).toList();
          } else {
            throw Exception('Expected List but got: ${decoded.runtimeType}');
          }
        } catch (e) {
          print('JSON decode error: $e');
          throw Exception('Failed to parse response: $e');
        }
      } else {
        throw Exception('Failed to load persons: Status ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('getPersons error: $e');
      if (e.toString().contains('SocketException') || e.toString().contains('Failed host lookup')) {
        throw Exception('Cannot connect to API. Make sure:\n1. Django server is running on http://127.0.0.1:8000\n2. For Android emulator, change URL to http://10.0.2.2:8000/api/persons/');
      }
      rethrow;
    }
  }

  static Future<Person> getPerson(int id) async {
    final response = await http.get(Uri.parse('${baseUrl}$id/'));
    if (response.statusCode == 200) {
      return Person.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load person');
    }
  }

  static Future<Person> createPerson(String name, int? born) async {
    try {
      final requestBody = json.encode({
        'name': name,
        'born': born,
      });
      
      print('POST Request URL: $baseUrl');
      print('POST Request Body: $requestBody');
      
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Connection timeout. Make sure Django API is running.');
        },
      );
      
      print('POST Response Status: ${response.statusCode}');
      print('POST Response Body: ${response.body}');
      
      if (response.statusCode == 201) {
        try {
          return Person.fromJson(json.decode(response.body) as Map<String, dynamic>);
        } catch (e) {
          print('Error parsing create response: $e');
          throw Exception('Failed to parse created person: $e');
        }
      } else {
        throw Exception('Failed to create person: Status ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('createPerson error: $e');
      if (e.toString().contains('SocketException') || e.toString().contains('Failed host lookup')) {
        throw Exception('Cannot connect to API. Make sure Django server is running on http://127.0.0.1:8000');
      }
      rethrow;
    }
  }

  static Future<Person> updatePerson(int id, String? name, int? born) async {
    Map<String, dynamic> body = {};
    if (name != null) body['name'] = name;
    if (born != null) body['born'] = born;

    final response = await http.patch(
      Uri.parse('${baseUrl}$id/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );
    if (response.statusCode == 200) {
      return Person.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update person');
    }
  }

  static Future<void> deletePerson(int id) async {
    final response = await http.delete(Uri.parse('${baseUrl}$id/'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete person');
    }
  }
}

class PersonListScreen extends StatefulWidget {
  const PersonListScreen({super.key});

  @override
  State<PersonListScreen> createState() => _PersonListScreenState();
}

class _PersonListScreenState extends State<PersonListScreen> {
  List<Person> _persons = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPersons();
  }

  Future<void> _loadPersons() async {
    setState(() {
      _isLoading = true;
    });
    try {
      print('Loading persons...');
      final persons = await PersonService.getPersons();
      print('Loaded ${persons.length} persons');
      setState(() {
        _persons = persons;
        _isLoading = false;
      });
    } catch (e) {
      print('_loadPersons error: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _loadPersons,
            ),
          ),
        );
      }
    }
  }

  Future<void> _addPerson() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PersonFormScreen()),
    );
    if (result == true) {
      _loadPersons();
    }
  }

  Future<void> _editPerson(Person person) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PersonFormScreen(person: person),
      ),
    );
    if (result == true) {
      _loadPersons();
    }
  }

  Future<void> _deletePerson(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Person'),
        content: const Text('Are you sure you want to delete this person?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await PersonService.deletePerson(id);
        _loadPersons();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Person deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting person: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Person CRUD'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPersons,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _persons.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('No persons found'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadPersons,
                        child: const Text('Refresh'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _persons.length,
                  itemBuilder: (context, index) {
                    final person = _persons[index];
                    return ListTile(
                      title: Text(person.name),
                      subtitle: Text(
                        person.born != null
                            ? 'Born: ${person.born}'
                            : 'Born: Not specified',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _editPerson(person),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deletePerson(person.id),
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPerson,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class PersonFormScreen extends StatefulWidget {
  final Person? person;

  const PersonFormScreen({super.key, this.person});

  @override
  State<PersonFormScreen> createState() => _PersonFormScreenState();
}

class _PersonFormScreenState extends State<PersonFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bornController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.person != null) {
      _nameController.text = widget.person!.name;
      if (widget.person!.born != null) {
        _bornController.text = widget.person!.born.toString();
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bornController.dispose();
    super.dispose();
  }

  Future<void> _savePerson() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final name = _nameController.text;
        final born = _bornController.text.isNotEmpty
            ? int.tryParse(_bornController.text)
            : null;

        if (widget.person == null) {
          await PersonService.createPerson(name, born);
        } else {
          await PersonService.updatePerson(
            widget.person!.id,
            name,
            born,
          );
        }

        if (mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.person == null
                  ? 'Person created successfully'
                  : 'Person updated successfully'),
            ),
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.person == null ? 'Add Person' : 'Edit Person'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bornController,
                decoration: const InputDecoration(
                  labelText: 'Born (Year)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _savePerson,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Text(widget.person == null ? 'Create' : 'Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

