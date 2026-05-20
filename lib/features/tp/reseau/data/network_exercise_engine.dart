import 'dart:math';

enum NetworkExerciseCategory {
  binaryConversion,
  ipClass,
  defaultMask,
  cidrNotation,
  subnetCalc,
}

class NetworkExercise {
  const NetworkExercise({
    required this.question,
    required this.correctAnswer,
    required this.explanation,
    this.hint,
  });

  final String question;
  final String correctAnswer;
  final String explanation;
  final String? hint;
}

class NetworkExerciseEngine {
  final _rng = Random();

  // ------------------------------------------------------------------ public

  NetworkExercise generate(NetworkExerciseCategory cat) => switch (cat) {
    NetworkExerciseCategory.binaryConversion => _genBinary(),
    NetworkExerciseCategory.ipClass          => _genIpClass(),
    NetworkExerciseCategory.defaultMask      => _genDefaultMask(),
    NetworkExerciseCategory.cidrNotation     => _genCidr(),
    NetworkExerciseCategory.subnetCalc       => _genSubnet(),
  };

  bool check(NetworkExercise ex, String answer) {
    final a = answer.trim().toLowerCase();
    final b = ex.correctAnswer.trim().toLowerCase();
    return a == b;
  }

  // ------------------------------------------------------------------ binary conversion

  NetworkExercise _genBinary() {
    if (_rng.nextBool()) {
      // decimal → binary
      final n = _rng.nextInt(256);
      return NetworkExercise(
        question: 'Convertissez $n en binaire (8 bits, sans espaces).',
        correctAnswer: n.toRadixString(2).padLeft(8, '0'),
        explanation: '$n = ${_explainDecToBin(n)}',
        hint: 'Divisez par 2 successivement.',
      );
    } else {
      // binary → decimal
      final n = _rng.nextInt(256);
      final bin = n.toRadixString(2).padLeft(8, '0');
      return NetworkExercise(
        question: 'Convertissez $bin (binaire) en decimal.',
        correctAnswer: '$n',
        explanation: '$bin = ${_explainBinToDec(bin)} = $n',
      );
    }
  }

  String _explainDecToBin(int n) {
    final bits = n.toRadixString(2).padLeft(8, '0');
    int value = n;
    final parts = <String>[];
    for (var i = 7; i >= 0; i--) {
      if (bits[7 - i] == '1') {
        parts.add('${pow(2, i).toInt()}');
      }
    }
    return parts.isEmpty ? '0' : parts.join(' + ');
  }

  String _explainBinToDec(String bin) {
    final parts = <String>[];
    for (var i = 0; i < 8; i++) {
      if (bin[i] == '1') {
        final exp = 7 - i;
        parts.add('${pow(2, exp).toInt()}');
      }
    }
    return parts.isEmpty ? '0' : parts.join(' + ');
  }

  // ------------------------------------------------------------------ ip class

  static const _classData = [
    ('10.0.0.1',     'A'),
    ('172.16.5.1',   'B'),
    ('192.168.1.1',  'C'),
    ('10.255.255.1', 'A'),
    ('172.31.0.1',   'B'),
    ('192.0.0.1',    'C'),
    ('100.64.0.1',   'A'),
    ('150.0.0.1',    'B'),
    ('200.10.5.3',   'C'),
    ('172.20.0.1',   'B'),
  ];

  NetworkExercise _genIpClass() {
    final entry = _classData[_rng.nextInt(_classData.length)];
    final ip    = entry.$1;
    final cls   = entry.$2;
    final first = int.parse(ip.split('.').first);

    return NetworkExercise(
      question: 'Quelle est la classe de l\'adresse IP $ip ? (repondez A, B ou C)',
      correctAnswer: cls,
      explanation: 'Le premier octet est $first. '
          'Classe A : 1-127, Classe B : 128-191, Classe C : 192-223.',
    );
  }

  // ------------------------------------------------------------------ default mask

  static const _maskData = {
    'A': '255.0.0.0',
    'B': '255.255.0.0',
    'C': '255.255.255.0',
  };

  NetworkExercise _genDefaultMask() {
    final cls  = ['A', 'B', 'C'][_rng.nextInt(3)];
    final mask = _maskData[cls]!;

    final questions = [
      'Quel est le masque par defaut de la classe $cls ?',
      'En notation pointee, quel est le masque par defaut pour une adresse de classe $cls ?',
    ];

    return NetworkExercise(
      question: questions[_rng.nextInt(questions.length)],
      correctAnswer: mask,
      explanation:
          'Classe $cls -> masque $mask (${cls == 'A' ? '/8' : cls == 'B' ? '/16' : '/24'}).',
    );
  }

  // ------------------------------------------------------------------ cidr

  NetworkExercise _genCidr() {
    if (_rng.nextBool()) {
      // mask → prefix
      final prefixes = [8, 16, 24, 25, 26, 27, 28, 29, 30];
      final prefix = prefixes[_rng.nextInt(prefixes.length)];
      final mask   = _prefixToMask(prefix);

      return NetworkExercise(
        question: 'Convertissez le masque $mask en notation CIDR (juste le nombre apres le /).',
        correctAnswer: '$prefix',
        explanation: '$mask = /$prefix ($prefix bits a 1 consecutifs).',
      );
    } else {
      // prefix → mask
      final prefixes = [8, 16, 24, 25, 26, 27, 28, 29, 30];
      final prefix = prefixes[_rng.nextInt(prefixes.length)];
      final mask   = _prefixToMask(prefix);

      return NetworkExercise(
        question: 'Convertissez /$prefix en masque de sous-reseau (notation pointee).',
        correctAnswer: mask,
        explanation: '/$prefix -> $mask ($prefix bits a 1, ${32 - prefix} bits a 0).',
      );
    }
  }

  String _prefixToMask(int prefix) {
    if (prefix == 0) return '0.0.0.0';
    final full  = prefix ~/ 8;
    final rem   = prefix % 8;
    final octs  = List<int>.filled(4, 0);
    for (var i = 0; i < full; i++) octs[i] = 255;
    if (full < 4 && rem > 0) {
      octs[full] = (256 - (1 << (8 - rem)));
    }
    return octs.join('.');
  }

  // ------------------------------------------------------------------ subnet calc

  NetworkExercise _genSubnet() {
    final scenarios = [
      _subnetQuestion(
        ip: '192.168.1.130',
        prefix: 25,
        field: 'network',
      ),
      _subnetQuestion(
        ip: '10.0.5.200',
        prefix: 24,
        field: 'broadcast',
      ),
      _subnetQuestion(
        ip: '172.16.10.50',
        prefix: 27,
        field: 'hosts',
      ),
      _subnetQuestion(
        ip: '192.168.100.65',
        prefix: 26,
        field: 'network',
      ),
      _subnetQuestion(
        ip: '10.10.20.130',
        prefix: 25,
        field: 'broadcast',
      ),
      _subnetQuestion(
        ip: '172.31.255.200',
        prefix: 28,
        field: 'hosts',
      ),
    ];
    return scenarios[_rng.nextInt(scenarios.length)];
  }

  NetworkExercise _subnetQuestion({
    required String ip,
    required int prefix,
    required String field,
  }) {
    final ipInt   = _ipToInt(ip);
    final maskInt = prefix == 0 ? 0 : (~0 << (32 - prefix)) & 0xFFFFFFFF;
    final netInt  = ipInt & maskInt;
    final bcastInt = netInt | (~maskInt & 0xFFFFFFFF);
    final hosts    = (bcastInt - netInt - 1).clamp(0, 1 << 30);

    final network   = _intToIp(netInt);
    final broadcast = _intToIp(bcastInt);

    return switch (field) {
      'network' => NetworkExercise(
          question:
              'Pour l\'adresse $ip/$prefix, quelle est l\'adresse reseau ? (notation pointee)',
          correctAnswer: network,
          explanation:
              'Masque = ${_prefixToMask(prefix)}. $ip AND masque = $network.',
        ),
      'broadcast' => NetworkExercise(
          question:
              'Pour $ip/$prefix, quelle est l\'adresse de broadcast ? (notation pointee)',
          correctAnswer: broadcast,
          explanation:
              'Reseau = $network. Broadcast = derniere adresse = $broadcast.',
        ),
      _ => NetworkExercise(
          question:
              'Combien d\'hotes utilisables dans le sous-reseau $ip/$prefix ?',
          correctAnswer: '$hosts',
          explanation:
              '2^${32 - prefix} - 2 = $hosts hotes. (reseau=$network, broadcast=$broadcast)',
        ),
    };
  }

  // ------------------------------------------------------------------ util

  int _ipToInt(String ip) {
    final parts = ip.split('.').map(int.parse).toList();
    return (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8) | parts[3];
  }

  String _intToIp(int n) {
    return [
      (n >> 24) & 0xFF,
      (n >> 16) & 0xFF,
      (n >> 8) & 0xFF,
      n & 0xFF,
    ].join('.');
  }
}
