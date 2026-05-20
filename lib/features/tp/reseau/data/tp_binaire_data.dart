// TP Binaire & Adressage IP — 15 TPs structurés (5 facile / 5 moyen / 5 difficile)

enum TpDifficulty { facile, moyen, difficile }

class TpSubQuestion {
  const TpSubQuestion({required this.label, required this.answer});
  final String label;
  final String answer;
}

class TpQuestion {
  const TpQuestion({
    required this.prompt,
    this.answer = '',
    this.points = 1,
    this.hint,
    this.subQuestions,
  });
  final String prompt;
  final String answer;
  final int points;
  final String? hint;
  final List<TpSubQuestion>? subQuestions;
}

class TpSection {
  const TpSection({
    required this.title,
    required this.instruction,
    required this.questions,
  });
  final String title;
  final String instruction;
  final List<TpQuestion> questions;
}

class TpBinaire {
  const TpBinaire({
    required this.id,
    required this.title,
    required this.difficulty,
    required this.sections,
  });
  final String id;
  final String title;
  final TpDifficulty difficulty;
  final List<TpSection> sections;

  int get totalPoints =>
      sections.expand((s) => s.questions).fold(0, (s, q) => s + q.points);

  String get difficultyLabel => switch (difficulty) {
        TpDifficulty.facile     => 'Facile',
        TpDifficulty.moyen      => 'Moyen',
        TpDifficulty.difficile  => 'Difficile',
      };
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

TpSection _s1(List<TpQuestion> qs) => TpSection(
      title: '1) Decimal → Binaire',
      instruction: 'Convertis chaque nombre decimal en binaire sur 8 bits.',
      questions: qs,
    );

TpSection _s2(List<TpQuestion> qs) => TpSection(
      title: '2) Binaire → Decimal',
      instruction: 'Convertis chaque octet binaire en decimal.',
      questions: qs,
    );

TpSection _s3(List<TpQuestion> qs) => TpSection(
      title: '3) Conversion IP + Classe',
      instruction:
          'Convertis l\'adresse IP et indique sa classe (A, B, C, D ou E).',
      questions: qs,
    );

TpSection _s4(List<TpQuestion> qs) => TpSection(
      title: '4) Masque par defaut + Classe',
      instruction: 'Donne le masque sous-reseau par defaut et la classe de chaque IP.',
      questions: qs,
    );

TpSection _s5(List<TpQuestion> qs) => TpSection(
      title: '5) Notation CIDR',
      instruction: 'Convertis chaque masque en notation /prefix CIDR.',
      questions: qs,
    );

TpSection _s6(List<TpQuestion> qs) => TpSection(
      title: '6) Calcul de sous-reseau',
      instruction:
          'A partir de l\'IP et du masque, calcule l\'adresse reseau, le broadcast, le nombre d\'hotes et la plage.',
      questions: qs,
    );

TpQuestion _dec2bin(String dec, String bin) => TpQuestion(
      prompt: '$dec :',
      answer: bin,
      hint: 'Divise par 2 successivement ou identifie les puissances de 2.',
    );

TpQuestion _bin2dec(String bin, String dec) => TpQuestion(
      prompt: '$bin :',
      answer: dec,
      hint: 'Additionne les puissances de 2 correspondant aux bits a 1.',
    );

TpQuestion _ipConv({
  required String prompt,
  required String conv,
  required String classe,
}) =>
    TpQuestion(
      prompt: prompt,
      points: 2,
      subQuestions: [
        TpSubQuestion(label: 'Conversion :', answer: conv),
        TpSubQuestion(label: 'Classe :', answer: classe),
      ],
    );

TpQuestion _defaultMask(String ip, String mask, String classe) => TpQuestion(
      prompt: '$ip :',
      points: 2,
      subQuestions: [
        TpSubQuestion(label: 'Masque par defaut :', answer: mask),
        TpSubQuestion(label: 'Classe :', answer: classe),
      ],
    );

TpQuestion _cidr(String mask, String prefix) => TpQuestion(
      prompt: '$mask :',
      answer: prefix,
      hint: 'Compte le nombre de bits a 1 dans le masque.',
    );

TpQuestion _subnet({
  required String prompt,
  required String network,
  required String hosts,
  required String broadcast,
  required String range,
}) =>
    TpQuestion(
      prompt: prompt,
      points: 4,
      subQuestions: [
        TpSubQuestion(label: 'Adresse reseau /CIDR :', answer: network),
        TpSubQuestion(label: 'Nombre d\'hotes :', answer: hosts),
        TpSubQuestion(label: 'Broadcast :', answer: broadcast),
        TpSubQuestion(label: 'Plage adressable :', answer: range),
      ],
    );

// ─── TP Facile 01 ─────────────────────────────────────────────────────────────

final tpFacile01 = TpBinaire(
  id: 'f01', title: 'TP N°1', difficulty: TpDifficulty.facile,
  sections: [
    _s1([
      _dec2bin('0',   '00000000'),
      _dec2bin('255', '11111111'),
      _dec2bin('128', '10000000'),
      _dec2bin('64',  '01000000'),
      _dec2bin('192', '11000000'),
      _dec2bin('10',  '00001010'),
    ]),
    _s2([
      _bin2dec('00000001', '1'),
      _bin2dec('11111110', '254'),
      _bin2dec('10000000', '128'),
      _bin2dec('01000000', '64'),
      _bin2dec('11000000', '192'),
      _bin2dec('00001111', '15'),
    ]),
    _s3([
      _ipConv(prompt: '10.0.0.1 en binaire ?',
              conv:   '00001010.00000000.00000000.00000001', classe: 'A'),
      _ipConv(prompt: '172.16.0.1 en binaire ?',
              conv:   '10101100.00010000.00000000.00000001', classe: 'B'),
      _ipConv(prompt: '192.168.1.1 en binaire ?',
              conv:   '11000000.10101000.00000001.00000001', classe: 'C'),
      _ipConv(prompt: '11001111.00000000.00000001.00000001 en decimal ?',
              conv:   '207.0.1.1', classe: 'C'),
      _ipConv(prompt: '10001010.00000000.00000000.00000001 en decimal ?',
              conv:   '138.0.0.1', classe: 'B'),
      _ipConv(prompt: '01111111.00000000.00000000.00000001 en decimal ?',
              conv:   '127.0.0.1', classe: 'A'),
    ]),
    _s4([
      _defaultMask('10.0.0.1',      '255.0.0.0',     'A'),
      _defaultMask('172.16.5.3',    '255.255.0.0',   'B'),
      _defaultMask('192.168.1.1',   '255.255.255.0', 'C'),
      _defaultMask('8.8.8.8',       '255.0.0.0',     'A'),
      _defaultMask('130.5.1.2',     '255.255.0.0',   'B'),
      _defaultMask('200.10.5.1',    '255.255.255.0', 'C'),
    ]),
    _s5([
      _cidr('255.0.0.0',       '/8'),
      _cidr('255.255.0.0',     '/16'),
      _cidr('255.255.255.0',   '/24'),
      _cidr('255.128.0.0',     '/9'),
      _cidr('255.255.128.0',   '/17'),
      _cidr('255.255.255.128', '/25'),
    ]),
    _s6([
      _subnet(prompt: 'IP : 192.168.1.0 / Masque : /24',
              network: '192.168.1.0/24', hosts: '254',
              broadcast: '192.168.1.255', range: '192.168.1.1 - 192.168.1.254'),
      _subnet(prompt: 'IP : 10.0.0.0 / Masque : /8',
              network: '10.0.0.0/8', hosts: '16777214',
              broadcast: '10.255.255.255', range: '10.0.0.1 - 10.255.255.254'),
      _subnet(prompt: 'IP : 172.16.0.0 / Masque : /16',
              network: '172.16.0.0/16', hosts: '65534',
              broadcast: '172.16.255.255', range: '172.16.0.1 - 172.16.255.254'),
      _subnet(prompt: 'IP : 192.168.10.0 / Masque : /24',
              network: '192.168.10.0/24', hosts: '254',
              broadcast: '192.168.10.255', range: '192.168.10.1 - 192.168.10.254'),
    ]),
  ],
);

// ─── TP Facile 02 ─────────────────────────────────────────────────────────────

final tpFacile02 = TpBinaire(
  id: 'f02', title: 'TP N°2', difficulty: TpDifficulty.facile,
  sections: [
    _s1([
      _dec2bin('1',   '00000001'),
      _dec2bin('127', '01111111'),
      _dec2bin('254', '11111110'),
      _dec2bin('32',  '00100000'),
      _dec2bin('16',  '00010000'),
      _dec2bin('224', '11100000'),
    ]),
    _s2([
      _bin2dec('00000010', '2'),
      _bin2dec('01111111', '127'),
      _bin2dec('11111110', '254'),
      _bin2dec('00100000', '32'),
      _bin2dec('10100000', '160'),
      _bin2dec('11110000', '240'),
    ]),
    _s3([
      _ipConv(prompt: '172.31.1.1 en binaire ?',
              conv:   '10101100.00011111.00000001.00000001', classe: 'B'),
      _ipConv(prompt: '10.1.2.3 en binaire ?',
              conv:   '00001010.00000001.00000010.00000011', classe: 'A'),
      _ipConv(prompt: '200.200.200.200 en binaire ?',
              conv:   '11001000.11001000.11001000.11001000', classe: 'C'),
      _ipConv(prompt: '10001100.00000000.00000001.00000001 en decimal ?',
              conv:   '140.0.1.1', classe: 'B'),
      _ipConv(prompt: '11000001.10101000.00000001.00000001 en decimal ?',
              conv:   '193.168.1.1', classe: 'C'),
      _ipConv(prompt: '00001100.00000000.00000000.00000001 en decimal ?',
              conv:   '12.0.0.1', classe: 'A'),
    ]),
    _s4([
      _defaultMask('12.0.0.1',      '255.0.0.0',     'A'),
      _defaultMask('140.0.1.1',     '255.255.0.0',   'B'),
      _defaultMask('193.168.1.1',   '255.255.255.0', 'C'),
      _defaultMask('100.10.1.1',    '255.0.0.0',     'A'),
      _defaultMask('150.20.30.1',   '255.255.0.0',   'B'),
      _defaultMask('210.5.6.1',     '255.255.255.0', 'C'),
    ]),
    _s5([
      _cidr('255.255.255.0',   '/24'),
      _cidr('255.192.0.0',     '/10'),
      _cidr('255.255.192.0',   '/18'),
      _cidr('255.255.255.192', '/26'),
      _cidr('255.240.0.0',     '/12'),
      _cidr('255.255.240.0',   '/20'),
    ]),
    _s6([
      _subnet(prompt: 'IP : 192.168.0.0 / Masque : /24',
              network: '192.168.0.0/24', hosts: '254',
              broadcast: '192.168.0.255', range: '192.168.0.1 - 192.168.0.254'),
      _subnet(prompt: 'IP : 10.10.0.0 / Masque : /16',
              network: '10.10.0.0/16', hosts: '65534',
              broadcast: '10.10.255.255', range: '10.10.0.1 - 10.10.255.254'),
      _subnet(prompt: 'IP : 172.20.0.0 / Masque : /16',
              network: '172.20.0.0/16', hosts: '65534',
              broadcast: '172.20.255.255', range: '172.20.0.1 - 172.20.255.254'),
      _subnet(prompt: 'IP : 192.168.100.0 / Masque : /24',
              network: '192.168.100.0/24', hosts: '254',
              broadcast: '192.168.100.255', range: '192.168.100.1 - 192.168.100.254'),
    ]),
  ],
);

// ─── TP Facile 03 ─────────────────────────────────────────────────────────────

final tpFacile03 = TpBinaire(
  id: 'f03', title: 'TP N°3', difficulty: TpDifficulty.facile,
  sections: [
    _s1([
      _dec2bin('4',   '00000100'),
      _dec2bin('8',   '00001000'),
      _dec2bin('15',  '00001111'),
      _dec2bin('96',  '01100000'),
      _dec2bin('240', '11110000'),
      _dec2bin('170', '10101010'),
    ]),
    _s2([
      _bin2dec('00000100', '4'),
      _bin2dec('00001000', '8'),
      _bin2dec('01100000', '96'),
      _bin2dec('11110000', '240'),
      _bin2dec('10101010', '170'),
      _bin2dec('01010101', '85'),
    ]),
    _s3([
      _ipConv(prompt: '192.168.50.1 en binaire ?',
              conv:   '11000000.10101000.00110010.00000001', classe: 'C'),
      _ipConv(prompt: '11.22.33.44 en binaire ?',
              conv:   '00001011.00010110.00100001.00101100', classe: 'A'),
      _ipConv(prompt: '185.100.1.1 en binaire ?',
              conv:   '10111001.01100100.00000001.00000001', classe: 'B'),
      _ipConv(prompt: '11000000.10101000.00000010.00000001 en decimal ?',
              conv:   '192.168.2.1', classe: 'C'),
      _ipConv(prompt: '10101100.00010000.00000001.00000001 en decimal ?',
              conv:   '172.16.1.1', classe: 'B'),
      _ipConv(prompt: '00001010.10000000.00000000.00000001 en decimal ?',
              conv:   '10.128.0.1', classe: 'A'),
    ]),
    _s4([
      _defaultMask('11.22.33.44',   '255.0.0.0',     'A'),
      _defaultMask('185.100.1.1',   '255.255.0.0',   'B'),
      _defaultMask('192.168.50.1',  '255.255.255.0', 'C'),
      _defaultMask('50.1.2.3',      '255.0.0.0',     'A'),
      _defaultMask('160.1.2.3',     '255.255.0.0',   'B'),
      _defaultMask('220.5.6.7',     '255.255.255.0', 'C'),
    ]),
    _s5([
      _cidr('255.0.0.0',       '/8'),
      _cidr('255.255.0.0',     '/16'),
      _cidr('255.255.255.0',   '/24'),
      _cidr('255.255.255.128', '/25'),
      _cidr('255.255.255.192', '/26'),
      _cidr('255.255.255.224', '/27'),
    ]),
    _s6([
      _subnet(prompt: 'IP : 192.168.5.0 / Masque : /24',
              network: '192.168.5.0/24', hosts: '254',
              broadcast: '192.168.5.255', range: '192.168.5.1 - 192.168.5.254'),
      _subnet(prompt: 'IP : 172.30.0.0 / Masque : /16',
              network: '172.30.0.0/16', hosts: '65534',
              broadcast: '172.30.255.255', range: '172.30.0.1 - 172.30.255.254'),
      _subnet(prompt: 'IP : 172.16.50.0 / Masque : /24',
              network: '172.16.50.0/24', hosts: '254',
              broadcast: '172.16.50.255', range: '172.16.50.1 - 172.16.50.254'),
      _subnet(prompt: 'IP : 10.0.0.0 / Masque : /8',
              network: '10.0.0.0/8', hosts: '16777214',
              broadcast: '10.255.255.255', range: '10.0.0.1 - 10.255.255.254'),
    ]),
  ],
);

// ─── TP Facile 04 ─────────────────────────────────────────────────────────────

final tpFacile04 = TpBinaire(
  id: 'f04', title: 'TP N°4', difficulty: TpDifficulty.facile,
  sections: [
    _s1([
      _dec2bin('33',  '00100001'),
      _dec2bin('65',  '01000001'),
      _dec2bin('100', '01100100'),
      _dec2bin('200', '11001000'),
      _dec2bin('128', '10000000'),
      _dec2bin('250', '11111010'),
    ]),
    _s2([
      _bin2dec('00100001', '33'),
      _bin2dec('01000001', '65'),
      _bin2dec('01100100', '100'),
      _bin2dec('11001000', '200'),
      _bin2dec('11111010', '250'),
      _bin2dec('11001100', '204'),
    ]),
    _s3([
      _ipConv(prompt: '192.0.2.1 en binaire ?',
              conv:   '11000000.00000000.00000010.00000001', classe: 'C'),
      _ipConv(prompt: '14.50.100.1 en binaire ?',
              conv:   '00001110.00110010.01100100.00000001', classe: 'A'),
      _ipConv(prompt: '130.90.1.1 en binaire ?',
              conv:   '10000010.01011010.00000001.00000001', classe: 'B'),
      _ipConv(prompt: '11000001.00000000.00000001.00000001 en decimal ?',
              conv:   '193.0.1.1', classe: 'C'),
      _ipConv(prompt: '10001001.00000000.00000001.00000001 en decimal ?',
              conv:   '137.0.1.1', classe: 'B'),
      _ipConv(prompt: '00001111.00000000.00000001.00000001 en decimal ?',
              conv:   '15.0.1.1', classe: 'A'),
    ]),
    _s4([
      _defaultMask('14.50.100.1',   '255.0.0.0',     'A'),
      _defaultMask('130.90.1.1',    '255.255.0.0',   'B'),
      _defaultMask('192.0.2.1',     '255.255.255.0', 'C'),
      _defaultMask('20.30.40.50',   '255.0.0.0',     'A'),
      _defaultMask('145.20.30.1',   '255.255.0.0',   'B'),
      _defaultMask('215.1.2.3',     '255.255.255.0', 'C'),
    ]),
    _s5([
      _cidr('255.255.255.0',   '/24'),
      _cidr('255.0.0.0',       '/8'),
      _cidr('255.255.0.0',     '/16'),
      _cidr('255.255.128.0',   '/17'),
      _cidr('255.255.255.128', '/25'),
      _cidr('255.255.192.0',   '/18'),
    ]),
    _s6([
      _subnet(prompt: 'IP : 172.16.0.0 / Masque : /16',
              network: '172.16.0.0/16', hosts: '65534',
              broadcast: '172.16.255.255', range: '172.16.0.1 - 172.16.255.254'),
      _subnet(prompt: 'IP : 192.168.30.0 / Masque : /24',
              network: '192.168.30.0/24', hosts: '254',
              broadcast: '192.168.30.255', range: '192.168.30.1 - 192.168.30.254'),
      _subnet(prompt: 'IP : 10.20.0.0 / Masque : /16',
              network: '10.20.0.0/16', hosts: '65534',
              broadcast: '10.20.255.255', range: '10.20.0.1 - 10.20.255.254'),
      _subnet(prompt: 'IP : 192.168.200.0 / Masque : /24',
              network: '192.168.200.0/24', hosts: '254',
              broadcast: '192.168.200.255', range: '192.168.200.1 - 192.168.200.254'),
    ]),
  ],
);

// ─── TP Facile 05 ─────────────────────────────────────────────────────────────

final tpFacile05 = TpBinaire(
  id: 'f05', title: 'TP N°5', difficulty: TpDifficulty.facile,
  sections: [
    _s1([
      _dec2bin('7',   '00000111'),
      _dec2bin('31',  '00011111'),
      _dec2bin('63',  '00111111'),
      _dec2bin('127', '01111111'),
      _dec2bin('159', '10011111'),
      _dec2bin('191', '10111111'),
    ]),
    _s2([
      _bin2dec('00000111', '7'),
      _bin2dec('00011111', '31'),
      _bin2dec('00111111', '63'),
      _bin2dec('10011111', '159'),
      _bin2dec('10111111', '191'),
      _bin2dec('11011111', '223'),
    ]),
    _s3([
      _ipConv(prompt: '1.2.3.4 en binaire ?',
              conv:   '00000001.00000010.00000011.00000100', classe: 'A'),
      _ipConv(prompt: '175.0.0.1 en binaire ?',
              conv:   '10101111.00000000.00000000.00000001', classe: 'B'),
      _ipConv(prompt: '222.100.1.1 en binaire ?',
              conv:   '11011110.01100100.00000001.00000001', classe: 'C'),
      _ipConv(prompt: '00000101.00000000.00000000.00000001 en decimal ?',
              conv:   '5.0.0.1', classe: 'A'),
      _ipConv(prompt: '10110000.00000000.00000000.00000001 en decimal ?',
              conv:   '176.0.0.1', classe: 'B'),
      _ipConv(prompt: '11001110.00000000.00000000.00000001 en decimal ?',
              conv:   '206.0.0.1', classe: 'C'),
    ]),
    _s4([
      _defaultMask('1.2.3.4',       '255.0.0.0',     'A'),
      _defaultMask('175.0.0.1',     '255.255.0.0',   'B'),
      _defaultMask('222.100.1.1',   '255.255.255.0', 'C'),
      _defaultMask('9.9.9.9',       '255.0.0.0',     'A'),
      _defaultMask('180.5.6.7',     '255.255.0.0',   'B'),
      _defaultMask('195.1.2.3',     '255.255.255.0', 'C'),
    ]),
    _s5([
      _cidr('255.0.0.0',       '/8'),
      _cidr('255.255.0.0',     '/16'),
      _cidr('255.255.255.0',   '/24'),
      _cidr('255.255.255.128', '/25'),
      _cidr('255.255.255.192', '/26'),
      _cidr('255.255.255.224', '/27'),
    ]),
    _s6([
      _subnet(prompt: 'IP : 10.0.0.0 / Masque : /8',
              network: '10.0.0.0/8', hosts: '16777214',
              broadcast: '10.255.255.255', range: '10.0.0.1 - 10.255.255.254'),
      _subnet(prompt: 'IP : 172.16.100.0 / Masque : /24',
              network: '172.16.100.0/24', hosts: '254',
              broadcast: '172.16.100.255', range: '172.16.100.1 - 172.16.100.254'),
      _subnet(prompt: 'IP : 192.168.50.0 / Masque : /24',
              network: '192.168.50.0/24', hosts: '254',
              broadcast: '192.168.50.255', range: '192.168.50.1 - 192.168.50.254'),
      _subnet(prompt: 'IP : 172.24.0.0 / Masque : /16',
              network: '172.24.0.0/16', hosts: '65534',
              broadcast: '172.24.255.255', range: '172.24.0.1 - 172.24.255.254'),
    ]),
  ],
);

// ─── TP Moyen 01 ─────────────────────────────────────────────────────────────

final tpMoyen01 = TpBinaire(
  id: 'm01', title: 'TP N°1', difficulty: TpDifficulty.moyen,
  sections: [
    _s1([
      _dec2bin('173', '10101101'),
      _dec2bin('89',  '01011001'),
      _dec2bin('204', '11001100'),
      _dec2bin('45',  '00101101'),
      _dec2bin('118', '01110110'),
      _dec2bin('237', '11101101'),
    ]),
    _s2([
      _bin2dec('10101101', '173'),
      _bin2dec('01011001', '89'),
      _bin2dec('11001100', '204'),
      _bin2dec('00101101', '45'),
      _bin2dec('01110110', '118'),
      _bin2dec('11101101', '237'),
    ]),
    _s3([
      _ipConv(prompt: '192.168.1.100 en binaire ?',
              conv:   '11000000.10101000.00000001.01100100', classe: 'C'),
      _ipConv(prompt: '10.50.25.12 en binaire ?',
              conv:   '00001010.00110010.00011001.00001100', classe: 'A'),
      _ipConv(prompt: '150.30.5.1 en binaire ?',
              conv:   '10010110.00011110.00000101.00000001', classe: 'B'),
      _ipConv(prompt: '11010000.10101000.00000001.00000001 en decimal ?',
              conv:   '208.168.1.1', classe: 'C'),
      _ipConv(prompt: '10000001.01100100.00000001.00000001 en decimal ?',
              conv:   '129.100.1.1', classe: 'B'),
      _ipConv(prompt: '00011010.00000000.00000001.00000001 en decimal ?',
              conv:   '26.0.1.1', classe: 'A'),
    ]),
    _s4([
      _defaultMask('26.0.1.1',      '255.0.0.0',     'A'),
      _defaultMask('129.100.1.1',   '255.255.0.0',   'B'),
      _defaultMask('208.168.1.1',   '255.255.255.0', 'C'),
      _defaultMask('75.100.1.1',    '255.0.0.0',     'A'),
      _defaultMask('170.30.1.1',    '255.255.0.0',   'B'),
      _defaultMask('198.51.100.1',  '255.255.255.0', 'C'),
    ]),
    _s5([
      _cidr('255.255.255.0',   '/24'),
      _cidr('255.255.255.128', '/25'),
      _cidr('255.255.255.192', '/26'),
      _cidr('255.255.224.0',   '/19'),
      _cidr('255.255.252.0',   '/22'),
      _cidr('255.255.255.240', '/28'),
    ]),
    _s6([
      _subnet(prompt: 'IP : 192.168.1.0 / Masque : /25',
              network: '192.168.1.0/25', hosts: '126',
              broadcast: '192.168.1.127', range: '192.168.1.1 - 192.168.1.126'),
      _subnet(prompt: 'IP : 172.16.48.0 / Masque : /22',
              network: '172.16.48.0/22', hosts: '1022',
              broadcast: '172.16.51.255', range: '172.16.48.1 - 172.16.51.254'),
      _subnet(prompt: 'IP : 10.20.30.0 / Masque : /26',
              network: '10.20.30.0/26', hosts: '62',
              broadcast: '10.20.30.63', range: '10.20.30.1 - 10.20.30.62'),
      _subnet(prompt: 'IP : 192.168.100.128 / Masque : /25',
              network: '192.168.100.128/25', hosts: '126',
              broadcast: '192.168.100.255', range: '192.168.100.129 - 192.168.100.254'),
    ]),
  ],
);

// ─── TP Moyen 02 ─────────────────────────────────────────────────────────────

final tpMoyen02 = TpBinaire(
  id: 'm02', title: 'TP N°2', difficulty: TpDifficulty.moyen,
  sections: [
    _s1([
      _dec2bin('142', '10001110'),
      _dec2bin('199', '11000111'),
      _dec2bin('57',  '00111001'),
      _dec2bin('213', '11010101'),
      _dec2bin('78',  '01001110'),
      _dec2bin('165', '10100101'),
    ]),
    _s2([
      _bin2dec('10001110', '142'),
      _bin2dec('11000111', '199'),
      _bin2dec('00111001', '57'),
      _bin2dec('11010101', '213'),
      _bin2dec('01001110', '78'),
      _bin2dec('10100101', '165'),
    ]),
    _s3([
      _ipConv(prompt: '10.150.200.1 en binaire ?',
              conv:   '00001010.10010110.11001000.00000001', classe: 'A'),
      _ipConv(prompt: '172.20.10.5 en binaire ?',
              conv:   '10101100.00010100.00001010.00000101', classe: 'B'),
      _ipConv(prompt: '203.0.113.5 en binaire ?',
              conv:   '11001011.00000000.01110001.00000101', classe: 'C'),
      _ipConv(prompt: '10011100.10000000.00000001.00000001 en decimal ?',
              conv:   '156.128.1.1', classe: 'B'),
      _ipConv(prompt: '11001111.10000000.00000001.00000001 en decimal ?',
              conv:   '207.128.1.1', classe: 'C'),
      _ipConv(prompt: '00011110.00000000.00000001.00000001 en decimal ?',
              conv:   '30.0.1.1', classe: 'A'),
    ]),
    _s4([
      _defaultMask('30.0.1.1',      '255.0.0.0',     'A'),
      _defaultMask('156.128.1.1',   '255.255.0.0',   'B'),
      _defaultMask('203.0.113.5',   '255.255.255.0', 'C'),
      _defaultMask('125.5.6.7',     '255.0.0.0',     'A'),
      _defaultMask('165.20.30.1',   '255.255.0.0',   'B'),
      _defaultMask('213.10.20.1',   '255.255.255.0', 'C'),
    ]),
    _s5([
      _cidr('255.255.255.0',   '/24'),
      _cidr('255.255.255.192', '/26'),
      _cidr('255.255.255.224', '/27'),
      _cidr('255.255.248.0',   '/21'),
      _cidr('255.255.254.0',   '/23'),
      _cidr('255.255.255.248', '/29'),
    ]),
    _s6([
      _subnet(prompt: 'IP : 10.96.0.0 / Masque : /21',
              network: '10.96.0.0/21', hosts: '2046',
              broadcast: '10.96.7.255', range: '10.96.0.1 - 10.96.7.254'),
      _subnet(prompt: 'IP : 192.168.10.0 / Masque : /26',
              network: '192.168.10.0/26', hosts: '62',
              broadcast: '192.168.10.63', range: '192.168.10.1 - 192.168.10.62'),
      _subnet(prompt: 'IP : 172.16.32.0 / Masque : /20',
              network: '172.16.32.0/20', hosts: '4094',
              broadcast: '172.16.47.255', range: '172.16.32.1 - 172.16.47.254'),
      _subnet(prompt: 'IP : 192.168.5.128 / Masque : /26',
              network: '192.168.5.128/26', hosts: '62',
              broadcast: '192.168.5.191', range: '192.168.5.129 - 192.168.5.190'),
    ]),
  ],
);

// ─── TP Moyen 03 ─────────────────────────────────────────────────────────────

final tpMoyen03 = TpBinaire(
  id: 'm03', title: 'TP N°3', difficulty: TpDifficulty.moyen,
  sections: [
    _s1([
      _dec2bin('111', '01101111'),
      _dec2bin('186', '10111010'),
      _dec2bin('43',  '00101011'),
      _dec2bin('229', '11100101'),
      _dec2bin('152', '10011000'),
      _dec2bin('75',  '01001011'),
    ]),
    _s2([
      _bin2dec('01101111', '111'),
      _bin2dec('10111010', '186'),
      _bin2dec('00101011', '43'),
      _bin2dec('11100101', '229'),
      _bin2dec('10011000', '152'),
      _bin2dec('01001011', '75'),
    ]),
    _s3([
      _ipConv(prompt: '192.168.200.50 en binaire ?',
              conv:   '11000000.10101000.11001000.00110010', classe: 'C'),
      _ipConv(prompt: '172.31.255.1 en binaire ?',
              conv:   '10101100.00011111.11111111.00000001', classe: 'B'),
      _ipConv(prompt: '25.100.50.1 en binaire ?',
              conv:   '00011001.01100100.00110010.00000001', classe: 'A'),
      _ipConv(prompt: '11001010.00000000.00000001.00000001 en decimal ?',
              conv:   '202.0.1.1', classe: 'C'),
      _ipConv(prompt: '10110100.00000000.00000001.00000001 en decimal ?',
              conv:   '180.0.1.1', classe: 'B'),
      _ipConv(prompt: '00110010.00000001.00000001.00000001 en decimal ?',
              conv:   '50.1.1.1', classe: 'A'),
    ]),
    _s4([
      _defaultMask('50.1.1.1',      '255.0.0.0',     'A'),
      _defaultMask('180.0.1.1',     '255.255.0.0',   'B'),
      _defaultMask('202.0.1.1',     '255.255.255.0', 'C'),
      _defaultMask('55.100.200.1',  '255.0.0.0',     'A'),
      _defaultMask('188.10.20.1',   '255.255.0.0',   'B'),
      _defaultMask('199.200.201.1', '255.255.255.0', 'C'),
    ]),
    _s5([
      _cidr('255.255.255.0',   '/24'),
      _cidr('255.255.255.128', '/25'),
      _cidr('255.255.255.240', '/28'),
      _cidr('255.255.192.0',   '/18'),
      _cidr('255.255.255.252', '/30'),
      _cidr('255.255.224.0',   '/19'),
    ]),
    _s6([
      _subnet(prompt: 'IP : 192.168.0.0 / Masque : /26',
              network: '192.168.0.0/26', hosts: '62',
              broadcast: '192.168.0.63', range: '192.168.0.1 - 192.168.0.62'),
      _subnet(prompt: 'IP : 10.0.0.0 / Masque : /23',
              network: '10.0.0.0/23', hosts: '510',
              broadcast: '10.0.1.255', range: '10.0.0.1 - 10.0.1.254'),
      _subnet(prompt: 'IP : 172.16.0.0 / Masque : /18',
              network: '172.16.0.0/18', hosts: '16382',
              broadcast: '172.16.63.255', range: '172.16.0.1 - 172.16.63.254'),
      _subnet(prompt: 'IP : 192.168.200.0 / Masque : /28',
              network: '192.168.200.0/28', hosts: '14',
              broadcast: '192.168.200.15', range: '192.168.200.1 - 192.168.200.14'),
    ]),
  ],
);

// ─── TP Moyen 04 ─────────────────────────────────────────────────────────────

final tpMoyen04 = TpBinaire(
  id: 'm04', title: 'TP N°4', difficulty: TpDifficulty.moyen,
  sections: [
    _s1([
      _dec2bin('99',  '01100011'),
      _dec2bin('177', '10110001'),
      _dec2bin('234', '11101010'),
      _dec2bin('56',  '00111000'),
      _dec2bin('123', '01111011'),
      _dec2bin('210', '11010010'),
    ]),
    _s2([
      _bin2dec('01100011', '99'),
      _bin2dec('10110001', '177'),
      _bin2dec('11101010', '234'),
      _bin2dec('00111000', '56'),
      _bin2dec('01111011', '123'),
      _bin2dec('11010010', '210'),
    ]),
    _s3([
      _ipConv(prompt: '172.16.254.254 en binaire ?',
              conv:   '10101100.00010000.11111110.11111110', classe: 'B'),
      _ipConv(prompt: '192.0.0.1 en binaire ?',
              conv:   '11000000.00000000.00000000.00000001', classe: 'C'),
      _ipConv(prompt: '100.200.100.1 en binaire ?',
              conv:   '01100100.11001000.01100100.00000001', classe: 'A'),
      _ipConv(prompt: '10000000.10000000.00000001.00000001 en decimal ?',
              conv:   '128.128.1.1', classe: 'B'),
      _ipConv(prompt: '11100000.10101000.00000001.00000001 en decimal ?',
              conv:   '224.168.1.1', classe: 'D'),
      _ipConv(prompt: '00100000.00000000.00000001.00000001 en decimal ?',
              conv:   '32.0.1.1', classe: 'A'),
    ]),
    _s4([
      _defaultMask('32.0.1.1',      '255.0.0.0',     'A'),
      _defaultMask('128.128.1.1',   '255.255.0.0',   'B'),
      _defaultMask('192.0.0.1',     '255.255.255.0', 'C'),
      _defaultMask('40.50.60.70',   '255.0.0.0',     'A'),
      _defaultMask('160.160.1.1',   '255.255.0.0',   'B'),
      _defaultMask('205.205.205.1', '255.255.255.0', 'C'),
    ]),
    _s5([
      _cidr('255.255.255.0',   '/24'),
      _cidr('255.255.128.0',   '/17'),
      _cidr('255.255.255.192', '/26'),
      _cidr('255.255.240.0',   '/20'),
      _cidr('255.255.255.248', '/29'),
      _cidr('255.255.252.0',   '/22'),
    ]),
    _s6([
      _subnet(prompt: 'IP : 192.168.10.64 / Masque : /26',
              network: '192.168.10.64/26', hosts: '62',
              broadcast: '192.168.10.127', range: '192.168.10.65 - 192.168.10.126'),
      _subnet(prompt: 'IP : 10.10.0.0 / Masque : /22',
              network: '10.10.0.0/22', hosts: '1022',
              broadcast: '10.10.3.255', range: '10.10.0.1 - 10.10.3.254'),
      _subnet(prompt: 'IP : 172.16.100.0 / Masque : /22',
              network: '172.16.100.0/22', hosts: '1022',
              broadcast: '172.16.103.255', range: '172.16.100.1 - 172.16.103.254'),
      _subnet(prompt: 'IP : 192.168.50.0 / Masque : /29',
              network: '192.168.50.0/29', hosts: '6',
              broadcast: '192.168.50.7', range: '192.168.50.1 - 192.168.50.6'),
    ]),
  ],
);

// ─── TP Moyen 05 ─────────────────────────────────────────────────────────────

final tpMoyen05 = TpBinaire(
  id: 'm05', title: 'TP N°5', difficulty: TpDifficulty.moyen,
  sections: [
    _s1([
      _dec2bin('88',  '01011000'),
      _dec2bin('147', '10010011'),
      _dec2bin('53',  '00110101'),
      _dec2bin('217', '11011001'),
      _dec2bin('166', '10100110'),
      _dec2bin('29',  '00011101'),
    ]),
    _s2([
      _bin2dec('01011000', '88'),
      _bin2dec('10010011', '147'),
      _bin2dec('00110101', '53'),
      _bin2dec('11011001', '217'),
      _bin2dec('10100110', '166'),
      _bin2dec('00011101', '29'),
    ]),
    _s3([
      _ipConv(prompt: '192.168.150.25 en binaire ?',
              conv:   '11000000.10101000.10010110.00011001', classe: 'C'),
      _ipConv(prompt: '10.255.255.254 en binaire ?',
              conv:   '00001010.11111111.11111111.11111110', classe: 'A'),
      _ipConv(prompt: '172.16.100.200 en binaire ?',
              conv:   '10101100.00010000.01100100.11001000', classe: 'B'),
      _ipConv(prompt: '11000000.00000000.00000010.00000001 en decimal ?',
              conv:   '192.0.2.1', classe: 'C'),
      _ipConv(prompt: '10110110.00000000.00000001.00000001 en decimal ?',
              conv:   '182.0.1.1', classe: 'B'),
      _ipConv(prompt: '01110100.00000000.00000001.00000001 en decimal ?',
              conv:   '116.0.1.1', classe: 'A'),
    ]),
    _s4([
      _defaultMask('116.0.1.1',       '255.0.0.0',     'A'),
      _defaultMask('182.0.1.1',       '255.255.0.0',   'B'),
      _defaultMask('192.168.150.25',  '255.255.255.0', 'C'),
      _defaultMask('22.33.44.55',     '255.0.0.0',     'A'),
      _defaultMask('155.100.200.1',   '255.255.0.0',   'B'),
      _defaultMask('223.5.10.1',      '255.255.255.0', 'C'),
    ]),
    _s5([
      _cidr('255.255.255.0',   '/24'),
      _cidr('255.255.255.128', '/25'),
      _cidr('255.255.255.192', '/26'),
      _cidr('255.255.255.224', '/27'),
      _cidr('255.255.255.240', '/28'),
      _cidr('255.255.255.252', '/30'),
    ]),
    _s6([
      _subnet(prompt: 'IP : 10.0.0.0 / Masque : /25',
              network: '10.0.0.0/25', hosts: '126',
              broadcast: '10.0.0.127', range: '10.0.0.1 - 10.0.0.126'),
      _subnet(prompt: 'IP : 172.16.200.0 / Masque : /24',
              network: '172.16.200.0/24', hosts: '254',
              broadcast: '172.16.200.255', range: '172.16.200.1 - 172.16.200.254'),
      _subnet(prompt: 'IP : 192.168.1.192 / Masque : /26',
              network: '192.168.1.192/26', hosts: '62',
              broadcast: '192.168.1.255', range: '192.168.1.193 - 192.168.1.254'),
      _subnet(prompt: 'IP : 10.1.0.0 / Masque : /22',
              network: '10.1.0.0/22', hosts: '1022',
              broadcast: '10.1.3.255', range: '10.1.0.1 - 10.1.3.254'),
    ]),
  ],
);

// ─── TP Difficile 01 ─────────────────────────────────────────────────────────

final tpDifficile01 = TpBinaire(
  id: 'd01', title: 'TP N°1', difficulty: TpDifficulty.difficile,
  sections: [
    _s1([
      _dec2bin('171', '10101011'),
      _dec2bin('85',  '01010101'),
      _dec2bin('219', '11011011'),
      _dec2bin('36',  '00100100'),
      _dec2bin('153', '10011001'),
      _dec2bin('107', '01101011'),
    ]),
    _s2([
      _bin2dec('10101011', '171'),
      _bin2dec('01010101', '85'),
      _bin2dec('11011011', '219'),
      _bin2dec('00100100', '36'),
      _bin2dec('10011001', '153'),
      _bin2dec('01101011', '107'),
    ]),
    _s3([
      _ipConv(prompt: '10.200.150.75 en binaire ?',
              conv:   '00001010.11001000.10010110.01001011', classe: 'A'),
      _ipConv(prompt: '192.168.100.200 en binaire ?',
              conv:   '11000000.10101000.01100100.11001000', classe: 'C'),
      _ipConv(prompt: '169.254.1.1 en binaire ?',
              conv:   '10101001.11111110.00000001.00000001', classe: 'B'),
      _ipConv(prompt: '11000111.10101010.00000001.00000001 en decimal ?',
              conv:   '199.170.1.1', classe: 'C'),
      _ipConv(prompt: '10000101.11001000.00000001.00000001 en decimal ?',
              conv:   '133.200.1.1', classe: 'B'),
      _ipConv(prompt: '00001100.11001000.00000001.00000001 en decimal ?',
              conv:   '12.200.1.1', classe: 'A'),
    ]),
    _s4([
      _defaultMask('12.200.1.1',    '255.0.0.0',     'A'),
      _defaultMask('133.200.1.1',   '255.255.0.0',   'B'),
      _defaultMask('199.170.1.1',   '255.255.255.0', 'C'),
      _defaultMask('7.77.77.77',    '255.0.0.0',     'A'),
      _defaultMask('135.135.135.1', '255.255.0.0',   'B'),
      _defaultMask('201.201.201.1', '255.255.255.0', 'C'),
    ]),
    _s5([
      _cidr('255.255.255.128', '/25'),
      _cidr('255.255.255.192', '/26'),
      _cidr('255.255.255.224', '/27'),
      _cidr('255.255.255.240', '/28'),
      _cidr('255.255.255.248', '/29'),
      _cidr('255.255.255.252', '/30'),
    ]),
    _s6([
      _subnet(prompt: 'IP : 10.10.10.0 / Masque : /27',
              network: '10.10.10.0/27', hosts: '30',
              broadcast: '10.10.10.31', range: '10.10.10.1 - 10.10.10.30'),
      _subnet(prompt: 'IP : 172.16.5.128 / Masque : /27',
              network: '172.16.5.128/27', hosts: '30',
              broadcast: '172.16.5.159', range: '172.16.5.129 - 172.16.5.158'),
      _subnet(prompt: 'IP : 192.168.1.0 / Masque : /29',
              network: '192.168.1.0/29', hosts: '6',
              broadcast: '192.168.1.7', range: '192.168.1.1 - 192.168.1.6'),
      _subnet(prompt: 'IP : 10.20.24.0 / Masque : /21',
              network: '10.20.24.0/21', hosts: '2046',
              broadcast: '10.20.31.255', range: '10.20.24.1 - 10.20.31.254'),
    ]),
  ],
);

// ─── TP Difficile 02 ─────────────────────────────────────────────────────────

final tpDifficile02 = TpBinaire(
  id: 'd02', title: 'TP N°2', difficulty: TpDifficulty.difficile,
  sections: [
    _s1([
      _dec2bin('203', '11001011'),
      _dec2bin('114', '01110010'),
      _dec2bin('67',  '01000011'),
      _dec2bin('178', '10110010'),
      _dec2bin('241', '11110001'),
      _dec2bin('59',  '00111011'),
    ]),
    _s2([
      _bin2dec('11001011', '203'),
      _bin2dec('01110010', '114'),
      _bin2dec('01000011', '67'),
      _bin2dec('10110010', '178'),
      _bin2dec('11110001', '241'),
      _bin2dec('00111011', '59'),
    ]),
    _s3([
      _ipConv(prompt: '192.0.2.100 en binaire ?',
              conv:   '11000000.00000000.00000010.01100100', classe: 'C'),
      _ipConv(prompt: '198.51.100.1 en binaire ?',
              conv:   '11000110.00110011.01100100.00000001', classe: 'C'),
      _ipConv(prompt: '100.64.0.1 en binaire ?',
              conv:   '01100100.01000000.00000000.00000001', classe: 'A'),
      _ipConv(prompt: '10101001.11111110.00000001.00000001 en decimal ?',
              conv:   '169.254.1.1', classe: 'B'),
      _ipConv(prompt: '11000110.10000000.00000001.00000001 en decimal ?',
              conv:   '198.128.1.1', classe: 'C'),
      _ipConv(prompt: '01100110.00000000.00000001.00000001 en decimal ?',
              conv:   '102.0.1.1', classe: 'A'),
    ]),
    _s4([
      _defaultMask('102.0.1.1',     '255.0.0.0',     'A'),
      _defaultMask('169.254.1.1',   '255.255.0.0',   'B'),
      _defaultMask('198.51.100.1',  '255.255.255.0', 'C'),
      _defaultMask('18.1.2.3',      '255.0.0.0',     'A'),
      _defaultMask('175.100.1.1',   '255.255.0.0',   'B'),
      _defaultMask('223.255.255.1', '255.255.255.0', 'C'),
    ]),
    _s5([
      _cidr('255.255.255.224', '/27'),
      _cidr('255.255.255.240', '/28'),
      _cidr('255.255.255.248', '/29'),
      _cidr('255.255.248.0',   '/21'),
      _cidr('255.255.252.0',   '/22'),
      _cidr('255.255.128.0',   '/17'),
    ]),
    _s6([
      _subnet(prompt: 'IP : 192.168.1.32 / Masque : /27',
              network: '192.168.1.32/27', hosts: '30',
              broadcast: '192.168.1.63', range: '192.168.1.33 - 192.168.1.62'),
      _subnet(prompt: 'IP : 172.16.0.0 / Masque : /21',
              network: '172.16.0.0/21', hosts: '2046',
              broadcast: '172.16.7.255', range: '172.16.0.1 - 172.16.7.254'),
      _subnet(prompt: 'IP : 10.10.20.0 / Masque : /29',
              network: '10.10.20.0/29', hosts: '6',
              broadcast: '10.10.20.7', range: '10.10.20.1 - 10.10.20.6'),
      _subnet(prompt: 'IP : 192.168.192.0 / Masque : /19',
              network: '192.168.192.0/19', hosts: '8190',
              broadcast: '192.168.223.255', range: '192.168.192.1 - 192.168.223.254'),
    ]),
  ],
);

// ─── TP Difficile 03 ─────────────────────────────────────────────────────────

final tpDifficile03 = TpBinaire(
  id: 'd03', title: 'TP N°3', difficulty: TpDifficulty.difficile,
  sections: [
    _s1([
      _dec2bin('131', '10000011'),
      _dec2bin('246', '11110110'),
      _dec2bin('17',  '00010001'),
      _dec2bin('189', '10111101'),
      _dec2bin('74',  '01001010'),
      _dec2bin('222', '11011110'),
    ]),
    _s2([
      _bin2dec('10000011', '131'),
      _bin2dec('11110110', '246'),
      _bin2dec('00010001', '17'),
      _bin2dec('10111101', '189'),
      _bin2dec('01001010', '74'),
      _bin2dec('11011110', '222'),
    ]),
    _s3([
      _ipConv(prompt: '10.1.2.3 en binaire ?',
              conv:   '00001010.00000001.00000010.00000011', classe: 'A'),
      _ipConv(prompt: '172.0.0.1 en binaire ?',
              conv:   '10101100.00000000.00000000.00000001', classe: 'B'),
      _ipConv(prompt: '192.88.99.1 en binaire ?',
              conv:   '11000000.01011000.01100011.00000001', classe: 'C'),
      _ipConv(prompt: '10100000.00000000.00000001.00000001 en decimal ?',
              conv:   '160.0.1.1', classe: 'B'),
      _ipConv(prompt: '11000011.00000000.00000001.00000001 en decimal ?',
              conv:   '195.0.1.1', classe: 'C'),
      _ipConv(prompt: '01001000.00000000.00000001.00000001 en decimal ?',
              conv:   '72.0.1.1', classe: 'A'),
    ]),
    _s4([
      _defaultMask('72.0.1.1',      '255.0.0.0',     'A'),
      _defaultMask('160.0.1.1',     '255.255.0.0',   'B'),
      _defaultMask('192.88.99.1',   '255.255.255.0', 'C'),
      _defaultMask('3.3.3.3',       '255.0.0.0',     'A'),
      _defaultMask('177.7.7.7',     '255.255.0.0',   'B'),
      _defaultMask('218.18.1.1',    '255.255.255.0', 'C'),
    ]),
    _s5([
      _cidr('255.255.255.128', '/25'),
      _cidr('255.255.255.224', '/27'),
      _cidr('255.255.255.248', '/29'),
      _cidr('255.255.240.0',   '/20'),
      _cidr('255.255.224.0',   '/19'),
      _cidr('255.255.255.252', '/30'),
    ]),
    _s6([
      _subnet(prompt: 'IP : 192.168.1.64 / Masque : /27',
              network: '192.168.1.64/27', hosts: '30',
              broadcast: '192.168.1.95', range: '192.168.1.65 - 192.168.1.94'),
      _subnet(prompt: 'IP : 10.0.0.0 / Masque : /20',
              network: '10.0.0.0/20', hosts: '4094',
              broadcast: '10.0.15.255', range: '10.0.0.1 - 10.0.15.254'),
      _subnet(prompt: 'IP : 172.16.16.0 / Masque : /20',
              network: '172.16.16.0/20', hosts: '4094',
              broadcast: '172.16.31.255', range: '172.16.16.1 - 172.16.31.254'),
      _subnet(prompt: 'IP : 10.96.0.0 / Masque : /19',
              network: '10.96.0.0/19', hosts: '8190',
              broadcast: '10.96.31.255', range: '10.96.0.1 - 10.96.31.254'),
    ]),
  ],
);

// ─── TP Difficile 04 ─────────────────────────────────────────────────────────

final tpDifficile04 = TpBinaire(
  id: 'd04', title: 'TP N°4', difficulty: TpDifficulty.difficile,
  sections: [
    _s1([
      _dec2bin('127', '01111111'),
      _dec2bin('253', '11111101'),
      _dec2bin('84',  '01010100'),
      _dec2bin('168', '10101000'),
      _dec2bin('51',  '00110011'),
      _dec2bin('195', '11000011'),
    ]),
    _s2([
      _bin2dec('01111111', '127'),
      _bin2dec('11111101', '253'),
      _bin2dec('01010100', '84'),
      _bin2dec('10101000', '168'),
      _bin2dec('00110011', '51'),
      _bin2dec('11000011', '195'),
    ]),
    _s3([
      _ipConv(prompt: '172.31.254.254 en binaire ?',
              conv:   '10101100.00011111.11111110.11111110', classe: 'B'),
      _ipConv(prompt: '192.168.255.255 en binaire ?',
              conv:   '11000000.10101000.11111111.11111111', classe: 'C'),
      _ipConv(prompt: '98.100.200.1 en binaire ?',
              conv:   '01100010.01100100.11001000.00000001', classe: 'A'),
      _ipConv(prompt: '10110011.10000000.00000001.00000001 en decimal ?',
              conv:   '179.128.1.1', classe: 'B'),
      _ipConv(prompt: '11001010.10101010.00000001.00000001 en decimal ?',
              conv:   '202.170.1.1', classe: 'C'),
      _ipConv(prompt: '01011000.01100100.00000001.00000001 en decimal ?',
              conv:   '88.100.1.1', classe: 'A'),
    ]),
    _s4([
      _defaultMask('88.100.1.1',    '255.0.0.0',     'A'),
      _defaultMask('179.128.1.1',   '255.255.0.0',   'B'),
      _defaultMask('202.170.1.1',   '255.255.255.0', 'C'),
      _defaultMask('66.6.6.6',      '255.0.0.0',     'A'),
      _defaultMask('145.50.100.1',  '255.255.0.0',   'B'),
      _defaultMask('214.100.200.1', '255.255.255.0', 'C'),
    ]),
    _s5([
      _cidr('255.255.255.240', '/28'),
      _cidr('255.255.255.248', '/29'),
      _cidr('255.255.255.252', '/30'),
      _cidr('255.255.248.0',   '/21'),
      _cidr('255.255.224.0',   '/19'),
      _cidr('255.255.128.0',   '/17'),
    ]),
    _s6([
      _subnet(prompt: 'IP : 192.168.1.96 / Masque : /27',
              network: '192.168.1.96/27', hosts: '30',
              broadcast: '192.168.1.127', range: '192.168.1.97 - 192.168.1.126'),
      _subnet(prompt: 'IP : 172.16.128.0 / Masque : /17',
              network: '172.16.128.0/17', hosts: '32766',
              broadcast: '172.16.255.255', range: '172.16.128.1 - 172.16.255.254'),
      _subnet(prompt: 'IP : 10.0.0.0 / Masque : /21',
              network: '10.0.0.0/21', hosts: '2046',
              broadcast: '10.0.7.255', range: '10.0.0.1 - 10.0.7.254'),
      _subnet(prompt: 'IP : 192.168.100.112 / Masque : /28',
              network: '192.168.100.112/28', hosts: '14',
              broadcast: '192.168.100.127', range: '192.168.100.113 - 192.168.100.126'),
    ]),
  ],
);

// ─── TP Difficile 05 ─────────────────────────────────────────────────────────

final tpDifficile05 = TpBinaire(
  id: 'd05', title: 'TP N°5', difficulty: TpDifficulty.difficile,
  sections: [
    _s1([
      _dec2bin('231', '11100111'),
      _dec2bin('94',  '01011110'),
      _dec2bin('163', '10100011'),
      _dec2bin('47',  '00101111'),
      _dec2bin('208', '11010000'),
      _dec2bin('137', '10001001'),
    ]),
    _s2([
      _bin2dec('11100111', '231'),
      _bin2dec('01011110', '94'),
      _bin2dec('10100011', '163'),
      _bin2dec('00101111', '47'),
      _bin2dec('11010000', '208'),
      _bin2dec('10001001', '137'),
    ]),
    _s3([
      _ipConv(prompt: '10.15.20.25 en binaire ?',
              conv:   '00001010.00001111.00010100.00011001', classe: 'A'),
      _ipConv(prompt: '172.16.255.0 en binaire ?',
              conv:   '10101100.00010000.11111111.00000000', classe: 'B'),
      _ipConv(prompt: '192.168.0.255 en binaire ?',
              conv:   '11000000.10101000.00000000.11111111', classe: 'C'),
      _ipConv(prompt: '11001101.01010101.00000001.00000001 en decimal ?',
              conv:   '205.85.1.1', classe: 'C'),
      _ipConv(prompt: '10011111.00000000.00000001.00000001 en decimal ?',
              conv:   '159.0.1.1', classe: 'B'),
      _ipConv(prompt: '00110100.00000000.00000001.00000001 en decimal ?',
              conv:   '52.0.1.1', classe: 'A'),
    ]),
    _s4([
      _defaultMask('52.0.1.1',      '255.0.0.0',     'A'),
      _defaultMask('159.0.1.1',     '255.255.0.0',   'B'),
      _defaultMask('192.168.0.255', '255.255.255.0', 'C'),
      _defaultMask('44.44.44.44',   '255.0.0.0',     'A'),
      _defaultMask('163.100.200.1', '255.255.0.0',   'B'),
      _defaultMask('222.100.50.1',  '255.255.255.0', 'C'),
    ]),
    _s5([
      _cidr('255.255.255.192', '/26'),
      _cidr('255.255.255.224', '/27'),
      _cidr('255.255.255.240', '/28'),
      _cidr('255.255.248.0',   '/21'),
      _cidr('255.255.252.0',   '/22'),
      _cidr('255.255.255.252', '/30'),
    ]),
    _s6([
      _subnet(prompt: 'IP : 192.168.10.240 / Masque : /28',
              network: '192.168.10.240/28', hosts: '14',
              broadcast: '192.168.10.255', range: '192.168.10.241 - 192.168.10.254'),
      _subnet(prompt: 'IP : 10.200.0.0 / Masque : /21',
              network: '10.200.0.0/21', hosts: '2046',
              broadcast: '10.200.7.255', range: '10.200.0.1 - 10.200.7.254'),
      _subnet(prompt: 'IP : 172.16.64.0 / Masque : /19',
              network: '172.16.64.0/19', hosts: '8190',
              broadcast: '172.16.95.255', range: '172.16.64.1 - 172.16.95.254'),
      _subnet(prompt: 'IP : 192.168.1.248 / Masque : /29',
              network: '192.168.1.248/29', hosts: '6',
              broadcast: '192.168.1.255', range: '192.168.1.249 - 192.168.1.254'),
    ]),
  ],
);

// ─── Catalogue ───────────────────────────────────────────────────────────────

final allTpBinaire = <TpBinaire>[
  tpFacile01, tpFacile02, tpFacile03, tpFacile04, tpFacile05,
  tpMoyen01,  tpMoyen02,  tpMoyen03,  tpMoyen04,  tpMoyen05,
  tpDifficile01, tpDifficile02, tpDifficile03, tpDifficile04, tpDifficile05,
];

List<TpBinaire> tpsByDifficulty(TpDifficulty d) =>
    allTpBinaire.where((t) => t.difficulty == d).toList();
