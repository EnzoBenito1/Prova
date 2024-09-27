import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

void main() => runApp(AgendaApp());

class AgendaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agenda de Contatos',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        snackBarTheme: SnackBarThemeData(
          backgroundColor: Colors.blue,
          contentTextStyle: TextStyle(color: Colors.white),
        ),
      ),
      home: ContactListScreen(),
    );
  }
}

class Contact {
  String name;
  String phone;
  String email;

  Contact({required this.name, required this.phone, required this.email});
}

class ContactListScreen extends StatefulWidget {
  @override
  _ContactListScreenState createState() => _ContactListScreenState();
}

class _ContactListScreenState extends State<ContactListScreen> {
  List<Contact> contacts = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Agenda de Contatos')),
      body: contacts.isEmpty
          ? Center(child: Text('Nenhum contato'))
          : ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(contacts[index].name),
            subtitle: Text(contacts[index].phone),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _removeContact(index),
            ),
            onTap: () => _editContact(index),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _addContact,
      ),
    );
  }

  void _addContact() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ContactFormScreen()),
    );
    if (result != null) {
      setState(() {
        contacts.add(result);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Contato adicionado')),
      );
    }
  }

  void _editContact(int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContactFormScreen(contact: contacts[index]),
      ),
    );
    if (result != null) {
      setState(() {
        contacts[index] = result;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Contato atualizado')),
      );
    }
  }

  void _removeContact(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmação'),
          content: Text('Excluir este contato?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Excluir'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  contacts.removeAt(index);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Contato removido!')),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class ContactFormScreen extends StatefulWidget {
  final Contact? contact;

  ContactFormScreen({this.contact});

  @override
  _ContactFormScreenState createState() => _ContactFormScreenState();
}

class _ContactFormScreenState extends State<ContactFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late String name;
  late String phone;
  late String email;

  final phoneMaskFormatter = MaskTextInputFormatter(
      mask: '(##) #####-####',
      filter: { "#": RegExp(r'[0-9]') },
      type: MaskAutoCompletionType.lazy
  );

  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  @override
  void initState() {
    super.initState();
    name = widget.contact?.name ?? '';
    phone = widget.contact?.phone ?? '';
    email = widget.contact?.email ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.contact == null ? 'Novo Contato' : 'Editar Contato'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              TextFormField(
                initialValue: name,
                decoration: InputDecoration(
                  labelText: 'Nome',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                  hintText: 'Paulo',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira um nome';
                  }
                  return null;
                },
                onSaved: (value) => name = value!,
              ),
              SizedBox(height: 16),
              TextFormField(
                initialValue: phone,
                decoration: InputDecoration(
                  labelText: 'Telefone',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                  hintText: '(67) 99517-9810',
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [phoneMaskFormatter],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira um telefone';
                  }
                  if (value.length < 14) {
                    return 'Por favor, insira um telefone válido';
                  }
                  return null;
                },
                onSaved: (value) => phone = value!,
              ),
              SizedBox(height: 16),
              TextFormField(
                initialValue: email,
                decoration: InputDecoration(
                  labelText: 'E-mail',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                  hintText: 'exemplo@email.com',
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira um e-mail';
                  }
                  if (!emailRegex.hasMatch(value)) {
                    return 'Por favor, insira um e-mail válido';
                  }
                  return null;
                },
                onSaved: (value) => email = value!,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                child: Text('Salvar'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    Navigator.pop(
                      context,
                      Contact(name: name, phone: phone, email: email),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}