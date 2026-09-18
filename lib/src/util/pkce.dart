import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

class PKCEUtil {
  static String? codeVerifier;
  static String? codeChallenge;

  static const _allowedChars =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';

  static String generateCodeVerifier() {
    final rng = Random.secure();
    final buffer = StringBuffer(64);
    for (var i = 0; i < 64; i++) {
      buffer.write(_allowedChars[rng.nextInt(_allowedChars.length)]);
    }
    codeVerifier = buffer.toString();
    return codeVerifier!;
  }

  static String computeCodeChallengeS256(String verifier) {
    if (verifier.isEmpty) {
      throw ArgumentError('Verifier cannot be null or empty');
    }

    final digest = sha256.convert(utf8.encode(verifier));
    // RFC 7636 requires base64url without padding
    codeChallenge = base64Url.encode(digest.bytes).replaceAll('=', '');
    return codeChallenge!;
  }
}
