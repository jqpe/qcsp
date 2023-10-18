import 'dart:io';
import 'package:test/test.dart';

void main() {
  final temp = Directory.systemTemp.path;

  setUp(() {
    if (!File("$temp/qcsp.exe").existsSync()) {
      Process.runSync(
        "dart",
        ["compile", "exe", "bin/qcsp.dart", "-o", "$temp/qcsp"],
      );
    }
  });

  test("binary works on target platform", () {
    final args = ["./test/fixtures/sample.txt"];
    final result = Process.runSync("$temp/qcsp", args);

    expect(result.exitCode, 0);
    expect(
      result.stdout.toString().trim(),
      "'sha256-IHv9k+ogbL3sTzCsMWY2JUXZIomxycgtoYoQqdJSIao='",
    );
  });
}
