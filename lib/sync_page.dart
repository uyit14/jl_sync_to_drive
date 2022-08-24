import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:path/path.dart' as path;
import 'google_auth_client.dart';

class SyncPage extends StatefulWidget {
  const SyncPage({Key? key}) : super(key: key);

  @override
  State<SyncPage> createState() => _SyncPageState();
}

class _SyncPageState extends State<SyncPage> {
  bool _loginStatus = false;
  bool _uploadDone = false;
  final googleSignIn = GoogleSignIn(scopes: [
    drive.DriveApi.driveAppdataScope,
    drive.DriveApi.driveFileScope,
  ]);

  List<File> files = [];

  Future<void> _signIn() async {
    final googleUser = await googleSignIn.signIn();

    try {
      if (googleUser != null) {
        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final UserCredential loginUser =
            await FirebaseAuth.instance.signInWithCredential(credential);

        assert(loginUser.user?.uid == FirebaseAuth.instance.currentUser?.uid);
        setState(() {
          _loginStatus = true;
        });
        if (kDebugMode) {
          print('sign in success');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('error $e');
      }
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    await googleSignIn.signOut();
    setState(() {
      _loginStatus = false;
    });
    print("Sign out");
  }

  //upload single file
  Future<void> _syncSingleFile() async {
    try {
      final driveApi = await _getDriveApi();
      if (driveApi == null) {
        return;
      }

      _showUploadingDialog();

      final folderId = await _getFolderId(driveApi);
      if (folderId == null) {
        await showMessage("Failure", "Error");
        return;
      }

      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        File file = File(result.files.single.path!);
        _uploadSingleFile(file, folderId, driveApi);
      } else {
        print("user cancel pick file");
      }
      // simulate a slow process
      await Future.delayed(const Duration(seconds: 2));
    } finally {
      Navigator.pop(context);
    }
  }

  //upload multi file
  void _pickMultiFile() async {
    setState(() {
      _uploadDone = false;
    });
    //
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result != null) {
      setState(() {
        files = result.paths.map((path) => File(path!)).toList();
      });
    } else {
      // User canceled the picker
    }
  }

  Future<void> _syncMultiFile() async {
    try {
      final driveApi = await _getDriveApi();
      if (driveApi == null) {
        return;
      }

      _showUploadingDialog();

      final folderId = await _getFolderId(driveApi);
      if (folderId == null) {
        await showMessage("Failure", "Error");
        return;
      }
      //
      for (var file in files) {
        _uploadSingleFile(file, folderId, driveApi);
      }
    } catch (e) {
      if (kDebugMode) {
        print("upload fail with error: ${e.toString()}");
      }
    } finally {
      if (kDebugMode) {
        print("upload success");
      }
      setState(() {
        files.clear();
        _uploadDone = true;
      });
      Navigator.pop(context);
    }
  }

  Future<String?> _getFolderId(drive.DriveApi driveApi) async {
    const mimeType = "application/vnd.google-apps.folder";
    String folderName = "JLFiles";

    try {
      final found = await driveApi.files.list(
        q: "mimeType = '$mimeType' and name = '$folderName'",
        $fields: "files(id, name)",
      );
      final files = found.files;
      if (files == null) {
        await showMessage("Sign-in first", "Error");
        return null;
      }

      if (files.isNotEmpty) {
        return files.first.id;
      }

      // Create a folder
      var folder = drive.File();
      folder.name = folderName;
      folder.mimeType = mimeType;
      final folderCreation = await driveApi.files.create(folder);
      if (kDebugMode) {
        print("folder name: ${folderCreation.name}");
      }

      return folderCreation.id;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      // I/flutter ( 6132): DetailedApiRequestError(status: 403, message: The granted scopes do not give access to all of the requested spaces.)
      return null;
    }
  }

  Future<drive.DriveApi?> _getDriveApi() async {
    final googleUser = await googleSignIn.signIn();
    final headers = await googleUser?.authHeaders;
    if (headers == null) {
      await showMessage("Please sign in first", "Error");
      return null;
    }

    final client = GoogleAuthClient(headers);
    final driveApi = drive.DriveApi(client);
    return driveApi;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: IndexedStack(
          alignment: Alignment.center,
          index: _loginStatus ? 1 : 0,
          children: [_googleSignInButton(), _uploadArea()],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: files.isNotEmpty ? () => _syncMultiFile() : null,
        backgroundColor: files.isNotEmpty ? Colors.blue : Colors.grey,
        child: const Icon(Icons.sync),
      ),
    );
  }

  Widget _googleSignInButton() {
    return ElevatedButton(
        onPressed: () async {
          if (await googleSignIn.isSignedIn()) {
            setState(() {
              _loginStatus = true;
            });
          } else {
            _signIn();
          }
        },
        child: const Text("Sign in to upload"));
  }

  Widget _uploadArea() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () => _pickMultiFile(),
          child: const Text("Pick a file to upload"),
        ),
        files.isNotEmpty
            ? Column(
                children: files
                    .map((file) => ListTile(
                          title: Text(path.basename(file.absolute.path)),
                          trailing: InkWell(
                              onTap: () {
                                setState(() {
                                  files.remove(file);
                                });
                              },
                              child: const Icon(Icons.close)),
                        ))
                    .toList(),
              )
            : Container(),
        _uploadDone
            ? Container(
                margin: const EdgeInsets.only(top: 16),
                child: const Text(
                  "Upload Done",
                  style: TextStyle(
                      color: Colors.green,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              )
            : Container()
      ],
    );
  }

  Future<void> showMessage(String msg, String title) async {
    final alert = AlertDialog(
      title: Text(title),
      content: Text(msg),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("OK"),
        ),
      ],
    );
    await showDialog(
      context: context,
      builder: (BuildContext context) => alert,
    );
  }

  void _showUploadingDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      transitionDuration: const Duration(seconds: 2),
      barrierColor: Colors.black.withOpacity(0.5),
      pageBuilder: (context, animation, secondaryAnimation) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  void _uploadSingleFile(
      File file, String folderId, drive.DriveApi driveApi) async {
    drive.File fileToUpload = drive.File();
    fileToUpload.parents = ["appDataFolder"];
    fileToUpload.name = path.basename(file.absolute.path);
    fileToUpload.modifiedTime = DateTime.now().toUtc();
    fileToUpload.parents = [folderId];
    // Upload to drive
    await driveApi.files.create(fileToUpload);
    if (kDebugMode) {
      print("success upload: ${fileToUpload.name} to drive");
    }
  }
}
