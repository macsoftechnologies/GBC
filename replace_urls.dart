import 'dart:io';

void main() {
  final dir = Directory('lib');
  if (!dir.existsSync()) {
    print('lib directory not found');
    return;
  }

  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  for (final file in files) {
    try {
      final content = file.readAsStringSync();
      
      var newContent = content.replaceAll('admin.gobuddyindia.com', 'dev.gobuddyindia.com');
      newContent = newContent.replaceAll('assets/images/appLogo.png', 'assets/images/logoImg.png');

      if (newContent != content) {
        file.writeAsStringSync(newContent);
        print('Updated ${file.path}');
      }
    } catch (e) {
      print('Error processing ${file.path}: $e');
    }
  }
}
