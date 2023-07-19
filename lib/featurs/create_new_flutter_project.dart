import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';

import '../core/pckages_created/custom_path_provider.dart';

class CreateFlutterProjectScreen extends StatefulWidget {
  const CreateFlutterProjectScreen({Key? key}) : super(key: key);

  @override
  _CreateFlutterProjectScreenState createState() => _CreateFlutterProjectScreenState();
}

class _CreateFlutterProjectScreenState extends State<CreateFlutterProjectScreen> {
  final _nameController = TextEditingController();
  final _pathController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _organizationController = TextEditingController();
  ProjectType _type = ProjectType.app;
  List<Platform> _platforms = [
    Platform.android,
    Platform.ios,
    Platform.web,
    Platform.windows,
    Platform.macos,
    Platform.linux,
  ];
  Language _androidLanguage = Language.java;
  Language _iosLanguage = Language.swift;

  String _androidSdkPath = '';

  bool _creatingProject = false;

  Future<void> _createProject() async {
    setState(() {
      _creatingProject = true;
    });

    final projectName = _nameController.text;
    final projectPath = _pathController.text;
    final projectDescription = _descriptionController.text;
    final organization = _organizationController.text;
    final projectType = _type;
    final platforms = _platforms;
    final androidLanguage = _androidLanguage;
    final iosLanguage = _iosLanguage;
    final androidSdkPath = await _getAndroidSdkPath();

    // TODO: Create the Flutter project using the given parameters

    setState(() {
      _creatingProject = false;
    });
  }

  Future<void> _selectPath(TextEditingController controller) async {
    final picker = WindowsDirectoryPicker(
      title: 'Select a directory',
      initialDirectory: 'C:\\',
      allowFolderCreation: true,
      showHidden: true,
      shape: Shape.CIRCLE,
      onDone: (directory) {
        print('Selected directory: $directory');
      },
    );

    final selectedDirectory = await picker.show();
    print('Selected directory: $selectedDirectory');
  }

  Future<String> _getAndroidSdkPath() async {
    final doctorResult = await Process.run('flutter', ['doctor', '-v']);
    final doctorOutput = doctorResult.stdout.toString();
    final androidSdkPathRegExp = RegExp(r'Android SDK at (.*)');

    final match = androidSdkPathRegExp.firstMatch(doctorOutput);
    if (match != null) {
      return match.group(1)!;
    } else {
      throw Exception('Failed to get Android SDK path from flutter doctor output');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Flutter Project'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Project Name',
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _pathController,
              decoration: const InputDecoration(
                labelText: 'Project Path',
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => _selectPath(_pathController),
              child: const Text('Select Path'),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _organizationController,
              decoration: const InputDecoration(
                labelText: 'Organization',
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<ProjectType>(
                    value: _type,
                    onChanged: (value) {
                      setState(() {
                        _type = value!;
                      });
                    },
                    items: ProjectType.values
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type.name),
                            ))
                        .toList(),
                    decoration: const InputDecoration(
                      labelText: 'Project Type',
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: DropdownButtonFormField<Language>(
                    value: _androidLanguage,
                    onChanged: (value) {
                      setState(() {
                        _androidLanguage = value!;
                      });
                    },
                    items: Language.values
                        .map((language) => DropdownMenuItem(
                              value: language,
                              child: Text(language.name),
                            ))
                        .toList(),
                    decoration: const InputDecoration(
                      labelText: 'Android Language',
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: DropdownButtonFormField<Language>(
                    value: _iosLanguage,
                    onChanged: (value) {
                      setState(() {
                        _iosLanguage = value!;
                      });
                    },
                    items: Language.values
                        .map((language) => DropdownMenuItem(
                              value: language,
                              child: Text(language.name),
                            ))
                        .toList(),
                    decoration: const InputDecoration(
                      labelText: 'iOS Language',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Text(
              'Platforms',
              style: Theme.of(context).textTheme.headline6,
            ),
            const SizedBox(height: 8.0),
            Wrap(
              spacing: 8.0,
              children: Platform.values
                  .map((platform) => FilterChip(
                        label: Text(platform.name),
                        selected: _platforms.contains(platform),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _platforms.add(platform);
                            } else {
                              _platforms.remove(platform);
                            }
                          });
                        },
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Android SDK Path: $_androidSdkPath',
              style: Theme.of(context).textTheme.subtitle1,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _creatingProject ? null : _createProject,
              child: _creatingProject ? const CircularProgressIndicator() : const Text('Create Project'),
            ),
          ],
        ),
      ),
    );
  }
}

enum ProjectType {
  app,
  package,
}

extension ProjectTypeName on ProjectType {
  String get name {
    switch (this) {
      case ProjectType.app:
        return 'App';
      case ProjectType.package:
        return 'Package';
      default:
        throw Exception('Unknown project type: $this');
    }
  }
}

enum Platform {
  android,
  ios,
  web,
  windows,
  macos,
  linux,
}

extension PlatformName on Platform {
  String get name {
    switch (this) {
      case Platform.android:
        return 'Android';
      case Platform.ios:
        return 'iOS';
      case Platform.web:
        return 'Web';
      case Platform.windows:
        return 'Windows';
      case Platform.macos:
        return 'macOS';
      case Platform.linux:
        return 'Linux';
      default:
        throw Exception('Unknown platform: $this');
    }
  }
}

enum Language {
  java,
  kotlin,
  swift,
  objc,
}

extension LanguageName on Language {
  String get name {
    switch (this) {
      case Language.java:
        return 'Java';
      case Language.kotlin:
        return 'Kotlin';
      case Language.swift:
        return 'Swift';
      case Language.objc:
        return 'Objective-C';
      default:
        throw Exception('Unknown language: $this');
    }
  }
}
