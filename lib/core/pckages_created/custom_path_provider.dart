import 'dart:io';

abstract class DirectoryChooser {
  String? title;
  String? initialDirectory;
  bool allowFolderCreation = false;
  bool showHidden = false;
  Function? onCancel;
  Function(Directory?)? onDone;

  Future<Directory?> show();
}

enum Shape { RECTANGLE, CIRCLE, TRIANGLE }

class WindowsDirectoryPicker implements DirectoryChooser {
  WindowsDirectoryPicker({
    this.title,
    this.initialDirectory,
    this.allowFolderCreation = false,
    this.showHidden = false,
    this.shape = Shape.RECTANGLE, // default to rectangle
    this.onCancel,
    this.onDone,
  });

  @override
  String? title;

  @override
  String? initialDirectory;

  @override
  bool allowFolderCreation;

  @override
  bool showHidden;

  final Shape shape; // add the shape as a property

  @override
  Function? onCancel;

  @override
  Function(Directory?)? onDone;

  @override
  Future<Directory?> show() async {
    final dialog = _WindowsDirectoryPickerDialog(
      title: title ?? 'Select a directory',
      initialDirectory: initialDirectory,
      allowFolderCreation: allowFolderCreation,
      showHidden: showHidden,
      shape: shape, // pass the shape to the dialog
    );

    final selectedDirectory = await dialog.show();

    onDone?.call(selectedDirectory);

    return selectedDirectory;
  }
}

class _WindowsDirectoryPickerDialog {
  _WindowsDirectoryPickerDialog({
    required this.title,
    this.initialDirectory,
    this.allowFolderCreation = false,
    this.showHidden = false,
    this.shape = Shape.RECTANGLE, // default to rectangle
  }) : assert(title.isNotEmpty);

  final String title;
  final String? initialDirectory;
  final bool allowFolderCreation;
  final bool showHidden;
  final Shape shape; // add the shape as a property

  Future<Directory?> show() async {
    final path = await _getDirectoryPath();
    if (path == null) {
      return null;
    }
    return Directory(path);
  }

  Future<String?> _getDirectoryPath() async {
    final command = <String>[
      'powershell.exe',
      '-Command',
      'Add-Type -AssemblyName System.Windows.Forms; '
          '\$dialog = New-Object System.Windows.Forms.FolderBrowserDialog; '
          '\$dialog.Description = "$title"; '
          'if ([System.IO.Directory]::Exists("$initialDirectory")) '
          '{ \$dialog.SelectedPath = "$initialDirectory"; } '
          '\$dialog.ShowNewFolderButton = $allowFolderCreation; '
          '\$dialog.ShowHidden = $showHidden; '
          'if (\$dialog.ShowDialog() -eq "OK") '
          '{ Write-Output \$dialog.SelectedPath }'
    ];

    final result = await Process.run(command[0], command.sublist(1));
    if (result.exitCode != 0) {
      return null;
    }

    return (result.stdout as String).trim();
  }
}