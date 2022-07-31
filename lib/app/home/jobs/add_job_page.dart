import 'package:flutter/material.dart';

class AddJobPage extends StatefulWidget {
  const AddJobPage({Key? key}) : super(key: key);

  static Future<void> show(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddJobPage(),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  State<AddJobPage> createState() => _AddJobPageState();
}

class _AddJobPageState extends State<AddJobPage> {
  final _formKey = GlobalKey<FormState>();
  String? _name;
  int? _ratePerHour;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        title: const Text('New Job'),
        actions: [
          FlatButton(
            onPressed: _submit,
            child: const Text(
              'Save',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ],
      ),
      body: _buildContents(),
      backgroundColor: Colors.grey[200],
    );
  }

  Widget _buildContents() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _buildForm(),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _buildFormChildren(),
      ),
    );
  }

  List<Widget> _buildFormChildren() {
    return [
      TextFormField(
        decoration: const InputDecoration(
          labelText: 'Job name',
        ),
        validator: (value) => value!.isNotEmpty ? null : 'Name can\'t be empty',
        onSaved: (value) => _name = value,
      ),
      TextFormField(
        decoration: const InputDecoration(
          labelText: 'Rate per hour',
        ),
        keyboardType:
            const TextInputType.numberWithOptions(signed: false, decimal: false),
        onSaved: (value) => _ratePerHour = int.parse(value!),
      ),
    ];
  }

  bool _validateAndSaveForm() {
    final form = _formKey.currentState!;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void _submit() {
    if (_validateAndSaveForm()) {
      print('form saved, name: $_name, ratePerHour: $_ratePerHour');
    }
  }
}

//Future<void> _createJob(BuildContext context) async {
//     try {
//       final database = Provider.of<Database>(context, listen: false);
//       await database.createJob(Job(name: 'Blogging', ratePerHour: 10));
//     } on FirebaseException catch (e) {
//       showExceptionAlertDialog(
//         context,
//         title: 'Operation failed',
//         exception: e,
//       );
//     }
//   }
