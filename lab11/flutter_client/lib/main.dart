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
    return Person(
      id: json['id'] as int,
      name: json['name'] as String,
      born: json['born'] as int?,
    );
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
  static const String baseUrl = 'http://127.0.0.1:8000/api/persons';

  static Future<List<Person>> getPersons() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Person.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load persons');
    }
  }

  static Future<Person> getPerson(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id/'));
    if (response.statusCode == 200) {
      return Person.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load person');
    }
  }

  static Future<Person> createPerson(String name, int? born) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'born': born,
      }),
    );
    if (response.statusCode == 201) {
      return Person.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create person');
    }
  }

  static Future<Person> updatePerson(int id, String? name, int? born) async {
    Map<String, dynamic> body = {};
    if (name != null) body['name'] = name;
    if (born != null) body['born'] = born;

    final response = await http.patch(
      Uri.parse('$baseUrl/$id/'),
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
    final response = await http.delete(Uri.parse('$baseUrl/$id/'));
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
      final persons = await PersonService.getPersons();
      setState(() {
        _persons = persons;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading persons: $e')),
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
              ? const Center(child: Text('No persons found'))
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
            SnackBar(content: Text('Error saving person: $e')),
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

