import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const Color _bg       = Color(0xFF1A1A2E);
const Color _violet   = Color(0xFF6C63FF);
const Color _cyan     = Color(0xFF00BCD4);
const Color _slate    = Color(0xFF94A3B8);
const Color _red      = Color(0xFFEF4444);
const Color _surface  = Color(0xFF252540);
const Color _surface2 = Color(0xFF2E2E50);

class SimpleCalculatorSheet extends StatefulWidget {
  const SimpleCalculatorSheet({super.key});

  @override
  State<SimpleCalculatorSheet> createState() => _SimpleCalculatorSheetState();
}

class _SimpleCalculatorSheetState extends State<SimpleCalculatorSheet> {
  String _expression = '';
  String _result = '0';
  double? _operand1;
  String? _operator;
  bool _waitingForOperand2 = false;
  bool _justEvaluated = false;

  // ── Input handlers ─────────────────────────────────────────────────────────

  void _onDigit(String d) {
    setState(() {
      if (_justEvaluated) {
        _expression = d;
        _justEvaluated = false;
      } else if (_waitingForOperand2) {
        _expression += d;
        _waitingForOperand2 = false;
      } else {
        _expression += d;
      }
      _updateResult();
    });
  }

  void _onDecimal() {
    if (_justEvaluated) {
      setState(() { _expression = '0.'; _justEvaluated = false; });
      return;
    }
    // find last number in expression
    final lastNum = _expression.split(RegExp(r'[+\-×÷^]')).last;
    if (lastNum.contains('.')) return;
    setState(() {
      _expression += lastNum.isEmpty ? '0.' : '.';
    });
  }

  void _onOperator(String op) {
    setState(() {
      if (_expression.isEmpty) {
        _expression = '0';
      }
      // Replace trailing operator
      final cleaned = _expression.trimRight();
      if (cleaned.isNotEmpty &&
          '+-×÷^'.contains(cleaned[cleaned.length - 1])) {
        _expression = cleaned.substring(0, cleaned.length - 1) + op;
      } else {
        _expression += op;
      }
      _waitingForOperand2 = true;
      _justEvaluated = false;
      _updateResult();
    });
  }

  void _onPower() => _onOperator('^');

  void _onEquals() {
    final computed = _evaluate(_expression);
    if (computed == null) return;
    setState(() {
      final fmt = _format(computed);
      _expression = fmt;
      _result = fmt;
      _justEvaluated = true;
      _operand1 = null;
      _operator = null;
    });
  }

  void _onClear() {
    setState(() {
      _expression = '';
      _result = '0';
      _operand1 = null;
      _operator = null;
      _waitingForOperand2 = false;
      _justEvaluated = false;
    });
  }

  void _onBackspace() {
    if (_expression.isEmpty) return;
    setState(() {
      _expression = _expression.substring(0, _expression.length - 1);
      _updateResult();
      _justEvaluated = false;
    });
  }

  void _updateResult() {
    final v = _evaluate(_expression);
    if (v != null) _result = _format(v);
  }

  // ── Evaluator ──────────────────────────────────────────────────────────────

  double? _evaluate(String expr) {
    if (expr.isEmpty) return null;
    try {
      return _evalSimple(expr.trim());
    } catch (_) {
      return null;
    }
  }

  // Supports: + - × ÷ ^ (left-to-right, no precedence — simple linear calc)
  double? _evalSimple(String expr) {
    if (expr.isEmpty) return null;
    // Tokenise: numbers and operators
    final tokens = <String>[];
    final current = StringBuffer();
    for (int i = 0; i < expr.length; i++) {
      final c = expr[i];
      if ('+-×÷^'.contains(c)) {
        // Allow leading minus
        if (c == '-' && (i == 0 || '+-×÷^'.contains(expr[i - 1]))) {
          current.write(c);
        } else {
          if (current.isNotEmpty) {
            tokens.add(current.toString());
            current.clear();
          }
          tokens.add(c);
        }
      } else {
        current.write(c);
      }
    }
    if (current.isNotEmpty) tokens.add(current.toString());

    if (tokens.isEmpty) return null;

    // Evaluate left-to-right
    double result = double.parse(tokens[0]);
    int i = 1;
    while (i < tokens.length - 1) {
      final op  = tokens[i];
      final rhs = double.parse(tokens[i + 1]);
      result = _apply(result, op, rhs);
      i += 2;
    }
    return result;
  }

  double _apply(double a, String op, double b) => switch (op) {
        '+' => a + b,
        '-' => a - b,
        '×' => a * b,
        '÷' => b == 0 ? double.nan : a / b,
        '^' => math.pow(a, b).toDouble(),
        _   => a,
      };

  String _format(double v) {
    if (v.isNaN) return 'Erreur';
    if (v.isInfinite) return 'Infini';
    if (v == v.truncateToDouble()) {
      // Show as integer if it fits without precision loss
      final asInt = v.toInt();
      if (asInt.toDouble() == v) return asInt.toString();
    }
    // Up to 10 significant digits
    final s = v.toStringAsPrecision(10).replaceAll(RegExp(r'0+$'), '');
    return s.endsWith('.') ? s.substring(0, s.length - 1) : s;
  }

  // ── Copy result ────────────────────────────────────────────────────────────

  void _copyResult() {
    Clipboard.setData(ClipboardData(text: _result));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Resultat copie dans le presse-papiers'),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF1A1A2E),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Row(
              children: [
                const Icon(Icons.calculate_rounded, color: _cyan, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Calculatrice',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: Colors.white.withValues(alpha: 0.5)),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(width: 32, height: 32),
                ),
              ],
            ),
          ),
          // Display
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Expression
                Text(
                  _expression.isEmpty ? '0' : _expression,
                  style: TextStyle(color: _slate, fontSize: 16, fontFamily: 'monospace'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                ),
                const SizedBox(height: 6),
                // Result
                Text(
                  _result,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'monospace',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: _copyResult,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _cyan.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _cyan.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.copy_rounded, color: _cyan, size: 13),
                          const SizedBox(width: 4),
                          const Text('Copier le resultat',
                              style: TextStyle(color: _cyan, fontSize: 11, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Column(
              children: [
                _row([
                  _btn('C',  onTap: _onClear,    bg: _red.withValues(alpha: 0.15), fg: _red),
                  _btn('⌫',  onTap: _onBackspace, bg: _surface2, fg: _slate),
                  _btn('xʸ', onTap: _onPower,     bg: _violet.withValues(alpha: 0.15), fg: _violet),
                  _btn('÷',  onTap: () => _onOperator('÷'), bg: _violet.withValues(alpha: 0.12), fg: _violet),
                ]),
                const SizedBox(height: 8),
                _row([
                  _btn('7', onTap: () => _onDigit('7')),
                  _btn('8', onTap: () => _onDigit('8')),
                  _btn('9', onTap: () => _onDigit('9')),
                  _btn('×', onTap: () => _onOperator('×'), bg: _violet.withValues(alpha: 0.12), fg: _violet),
                ]),
                const SizedBox(height: 8),
                _row([
                  _btn('4', onTap: () => _onDigit('4')),
                  _btn('5', onTap: () => _onDigit('5')),
                  _btn('6', onTap: () => _onDigit('6')),
                  _btn('-', onTap: () => _onOperator('-'), bg: _violet.withValues(alpha: 0.12), fg: _violet),
                ]),
                const SizedBox(height: 8),
                _row([
                  _btn('1', onTap: () => _onDigit('1')),
                  _btn('2', onTap: () => _onDigit('2')),
                  _btn('3', onTap: () => _onDigit('3')),
                  _btn('+', onTap: () => _onOperator('+'), bg: _violet.withValues(alpha: 0.12), fg: _violet),
                ]),
                const SizedBox(height: 8),
                _row([
                  _btn('0',   onTap: () => _onDigit('0'), flex: 2),
                  _btn('.',   onTap: _onDecimal),
                  _btn('=',   onTap: _onEquals, bg: _violet, fg: Colors.white),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(List<Widget> children) => Row(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            children[i],
          ],
        ],
      );

  Widget _btn(
    String label, {
    required VoidCallback onTap,
    Color? bg,
    Color? fg,
    int flex = 1,
  }) {
    final bgColor  = bg  ?? _surface2;
    final fgColor  = fg  ?? Colors.white;
    return Expanded(
      flex: flex,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: fgColor,
              fontSize: label.length > 1 ? 14 : 18,
              fontWeight: FontWeight.w600,
              fontFamily: label == 'xʸ' ? null : 'monospace',
            ),
          ),
        ),
      ),
    );
  }
}
