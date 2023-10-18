import 'dart:async';

import 'package:qcsp/qcsp.dart';
import 'package:test/test.dart';

void main() {
  test('hashFile', () async {
    final algo = SupportedHashAlgorithm.sha256;
    final hash = await hashFile(sampleFilePath, algo);
    final base64 = hashToBase64String(hash);

    expect(base64, "IHv9k+ogbL3sTzCsMWY2JUXZIomxycgtoYoQqdJSIao=");
  });

  test("toSource", () {
    final source = toHashSource("xyd", SupportedHashAlgorithm.sha256);
    expect(source, "'sha256-xyd'");
  });

  test("supported hash algorithms to iterable", () {
    final iterable = SupportedHashAlgorithm.toStringIterable();

    expect(iterable.first, "sha256");
  });

  group("command runner", () {
    final runner = CommandRunner();
    var log = [];

    tearDown(() {
      log = [];
    });

    /// Mock all `print` calls to add to `log` instead
    overridePrint(void Function() testFn) => () {
          final spec = ZoneSpecification(print: (_, __, ___, String msg) {
            // Add to log instead of printing to stdout
            log.add(msg);
          });
          return Zone.current.fork(specification: spec).run<void>(testFn);
        };

    test("prints help information with no arguments", overridePrint(() async {
      await runner.run([]);
      expect(log.first, runner.help);
    }));

    test("prints help information with -h flag", overridePrint(() async {
      await runner.run(["-h"]);
      expect(log.first, runner.help);
    }));

    test("prints help information with --help flag", overridePrint(() async {
      await runner.run(["--help"]);
      expect(log.first, runner.help);
    }));

    group("algorithms", () {
      test("SHA 256", overridePrint(() async {
        await runner.run([sampleFilePath]);

        expect(log.first, sourceSha256);
      }));

      test("SHA 384", overridePrint(() async {
        await runner.run([sampleFilePath, "-asha384"]);

        expect(log.first, sourceSha384);
      }));

      test("SHA 512", overridePrint(() async {
        await runner.run([sampleFilePath, "-asha512"]);

        expect(log.first, sourceSha512);
      }));
    });
  });
}

const sampleFilePath = "./test/fixtures/sample.txt";
const sourceSha256 = "'sha256-IHv9k+ogbL3sTzCsMWY2JUXZIomxycgtoYoQqdJSIao='";
const sourceSha384 =
    "'sha384-NCTzxNstWh1GOHd48dOlonrGPfe6bi/3KJKFBjK9h5tjqbEvadNVcPWZZvGCdrEy'";

const sourceSha512 =
    "'sha512-ZyqZkrBqC6ZzelBn/x6SR7j9dW0UAeKmukQKlogumboXUQ9WN9wyFsq87pm/7f4HZBatVqXbVjuU7/TaeFsynw=='";
