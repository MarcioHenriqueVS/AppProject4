import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' show File;
import 'Perfil_Services.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late User _user;
  late String _photoUrl;
  final TextEditingController _displayNameController = TextEditingController();
  final ProfileDataService _profileDataService = ProfileDataService();

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser!;
    _photoUrl = _user.photoURL!;
  }

  Future<void> _pickImage() async {
    if (kIsWeb) {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null) {
        final fileBytes = result.files.first.bytes!;
        final photoUrl = await _profileDataService.uploadImage(fileBytes);
        setState(() {
          _photoUrl = photoUrl;
        });
        await _profileDataService.updatePhotoURL(photoUrl);
      }
    } else {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final fileBytes = await file.readAsBytes();
        final photoUrl = await _profileDataService.uploadImage(fileBytes);
        setState(() {
          _photoUrl = photoUrl;
        });
        await _profileDataService.updatePhotoURL(photoUrl);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = _user.displayName ?? '';
    final email = _user.email ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
      ),
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(_photoUrl),
              ),
              TextButton(
                onPressed: _pickImage,
                child: const Text('Alterar foto de perfil'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit),
                    color: Colors.blue,
                    onPressed: _showUpdateDisplayNameDialog,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    email,
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit),
                    color: Colors.blue,
                    onPressed: _showUpdateEmailDialog,
                  ),
                ],
              ),
            ]),
      ),
    );
  }

  Future<void> _updateDisplayName(String newDisplayName) async {
    await _profileDataService.updateDisplayName(newDisplayName);

    setState(() {
      _user = FirebaseAuth.instance.currentUser!;
    });
  }

  void _showUpdateDisplayNameDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Atualizar nome de usuário'),
        content: TextField(
          controller: _displayNameController,
          decoration:
              InputDecoration(hintText: 'Digite o novo nome de usuário'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await _profileDataService.addName(_displayNameController.text);
              _displayNameController.clear();
              Navigator.of(context).pop();
            },
            child: Text('Atualizar'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateEmail(String email) async {
  }

  Future<void> _showUpdateEmailDialog() async {
    String? newEmail;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return const AlertDialog(
          title: Text('Não é possível trocar o e-mail'),
        );
      }
    );
  }
}
