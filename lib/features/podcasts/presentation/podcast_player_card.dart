import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../../../shared/widgets/eskolia_card.dart';

const Color _cyan = Color(0xFF00BCD4);
const Color _violet = Color(0xFF6C63FF);
const Color _slate = Color(0xFF94A3B8);
const Color _danger = Color(0xFFFF6584);

/// Lecteur autonome pour un seul podcast — reutilisable en tete de module.
/// Streame le .m4a depuis son URL (release GitHub) ; la lecture est declenchee
/// au tap (politique autoplay du web respectee).
class PodcastPlayerCard extends StatefulWidget {
  const PodcastPlayerCard({
    super.key,
    required this.title,
    required this.url,
    this.subtitle,
  });

  final String title;
  final String url;
  final String? subtitle;

  @override
  State<PodcastPlayerCard> createState() => _PodcastPlayerCardState();
}

class _PodcastPlayerCardState extends State<PodcastPlayerCard> {
  final AudioPlayer _player = AudioPlayer();
  final List<StreamSubscription<dynamic>> _subs = [];

  PlayerState _state = PlayerState.stopped;
  Duration _position = Duration.zero;
  Duration? _duration;
  bool _started = false;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _player.setReleaseMode(ReleaseMode.stop);
    _subs.add(_player.onPlayerStateChanged.listen((s) {
      if (!mounted) return;
      setState(() => _state = s);
    }));
    _subs.add(_player.onDurationChanged.listen((d) {
      if (!mounted) return;
      setState(() => _duration = d);
    }));
    _subs.add(_player.onPositionChanged.listen((p) {
      if (!mounted) return;
      setState(() => _position = p);
    }));
    _subs.add(_player.onPlayerComplete.listen((_) {
      if (!mounted) return;
      setState(() {
        _state = PlayerState.completed;
        _position = Duration.zero;
        _started = false;
      });
      _ActivePlayer.clear(this);
    }));
  }

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    _player.dispose();
    _ActivePlayer.clear(this);
    super.dispose();
  }

  Future<void> _toggle() async {
    try {
      if (_state == PlayerState.playing) {
        await _player.pause();
        return;
      }
      _ActivePlayer.setActive(this);
      if (_started) {
        await _player.resume();
        return;
      }
      setState(() {
        _loading = true;
        _error = null;
      });
      await _player.play(UrlSource(widget.url));
      _started = true;
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Lecture impossible. Verifie ta connexion.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pauseFromRegistry() async {
    if (_state == PlayerState.playing) await _player.pause();
  }

  Future<void> _seekTo(double ms) async {
    await _player.seek(Duration(milliseconds: ms.round()));
  }

  static String _fmt(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s < 10 ? '0$s' : '$s'}';
  }

  @override
  Widget build(BuildContext context) {
    final playing = _state == PlayerState.playing;
    final total = _duration ?? Duration.zero;
    final hasDuration = total.inMilliseconds > 0;
    final pos = _position.inMilliseconds
        .clamp(0, hasDuration ? total.inMilliseconds : 0)
        .toDouble();

    const timeStyle = TextStyle(color: _slate, fontSize: 11, fontWeight: FontWeight.w600);

    return EskoliaCardContent(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _PlayButton(playing: playing, loading: _loading, onTap: _toggle),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                    if (widget.subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        widget.subtitle!,
                        style: const TextStyle(color: _slate, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.graphic_eq_rounded,
                color: _cyan.withValues(alpha: 0.7),
                size: 20,
              ),
            ],
          ),
          if (hasDuration || _started) ...[
            const SizedBox(height: 8),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 3,
                activeTrackColor: _cyan,
                inactiveTrackColor: Colors.white.withValues(alpha: 0.15),
                thumbColor: _cyan,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              ),
              child: Slider(
                value: pos,
                max: hasDuration ? total.inMilliseconds.toDouble() : 1.0,
                onChanged: hasDuration
                    ? (v) => setState(
                          () => _position = Duration(milliseconds: v.round()),
                        )
                    : null,
                onChangeEnd: hasDuration ? _seekTo : null,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_fmt(_position), style: timeStyle),
                  Text(hasDuration ? _fmt(total) : '--:--', style: timeStyle),
                ],
              ),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(color: _danger, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}

/// Coordonne les lecteurs : demarrer un podcast met en pause le precedent.
abstract final class _ActivePlayer {
  _ActivePlayer._();

  static _PodcastPlayerCardState? _current;

  static void setActive(_PodcastPlayerCardState s) {
    final prev = _current;
    if (prev != null && prev != s) prev._pauseFromRegistry();
    _current = s;
  }

  static void clear(_PodcastPlayerCardState s) {
    if (_current == s) _current = null;
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton({
    required this.playing,
    required this.loading,
    required this.onTap,
  });

  final bool playing;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: loading ? null : onTap,
        borderRadius: BorderRadius.circular(26),
        child: Container(
          width: 52,
          height: 52,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_cyan, _violet],
            ),
          ),
          child: loading
              ? const Padding(
                  padding: EdgeInsets.all(15),
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: Colors.white,
                  ),
                )
              : Icon(
                  playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 30,
                ),
        ),
      ),
    );
  }
}
