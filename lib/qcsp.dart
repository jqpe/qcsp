import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cryptography/cryptography.dart';

export 'package:qcsp/cli.dart';

/// Reads an utf8 encoded file from the filesystem and hashes the file using `algo`
Future<Hash> hashFile(String path, SupportedHashAlgorithm algo) async {
  final hashSink = algo.implementation().newHashSink();

  // Ensure all platform specific carriage return and line feed are replaced with just line feeds
  final consistentLines = StreamTransformer<String, String>.fromHandlers(
      handleData: (String value, EventSink<String> sink) {
    final normalizedLine = value.replaceAll(RegExp(r'\r\n|\r|\n'), '\n');

    sink.add(normalizedLine);
  });

  return File(path)
      .openRead()
      .transform(utf8.decoder)
      .transform(consistentLines)
      .listen((line) => hashSink.add(line.codeUnits))
      .asFuture()
      .then((value) {
    hashSink.close();
    return hashSink.hash();
  });
}

String hashToBase64String(Hash hash) {
  return base64.encode(hash.bytes);
}

/// [From the specification](https://www.w3.org/TR/CSP/#grammardef-hash-source)
///
/// ```txt
/// hash-source  = "'" hash-algorithm "-" base64-value "'"
/// ```
String toHashSource(String base64, SupportedHashAlgorithm algo) {
  return "'${algo.name}-$base64'";
}

/// Hash algorithms supported by [CSP 2](https://www.w3.org/TR/CSP2/), currently `sha256`, `sha384` and `sha512`.
enum SupportedHashAlgorithm {
  sha256,
  sha384,
  sha512;

  static SupportedHashAlgorithm parse(String algorihm) {
    switch (algorihm) {
      case "sha256":
        return SupportedHashAlgorithm.sha256;
      case "sha384":
        return SupportedHashAlgorithm.sha384;
      case "sha512":
        return SupportedHashAlgorithm.sha512;
      default:
        throw UnimplementedError("$algorihm is not supported");
    }
  }

  static Iterable<String> toStringIterable() {
    return SupportedHashAlgorithm.values.map((e) => e.name);
  }
}

extension on SupportedHashAlgorithm {
  HashAlgorithm implementation() {
    return switch (this) {
      SupportedHashAlgorithm.sha256 => Sha256(),
      SupportedHashAlgorithm.sha384 => Sha384(),
      SupportedHashAlgorithm.sha512 => Sha512(),
    };
  }
}
