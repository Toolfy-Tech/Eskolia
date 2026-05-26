import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/services/asset_cache_service.dart';

import '../../../core/theme/eskolia_layout.dart';
import '../../../core/theme/eskolia_visual.dart';
import '../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../shared/widgets/eskolia_app_bar.dart';
import '../../../shared/widgets/eskolia_lesson_markdown.dart';
import '../../../shared/widgets/eskolia_card.dart';

/// Affiche un tutoriel Markdown depuis un asset bundle.
class PracticalMarkdownScreen extends StatefulWidget {
  const PracticalMarkdownScreen({
    super.key,
    required this.assetPath,
    required this.title,
  });

  final String assetPath;
  final String title;

  @override
  State<PracticalMarkdownScreen> createState() =>
      _PracticalMarkdownScreenState();
}

class _PracticalMarkdownScreenState extends State<PracticalMarkdownScreen> {
  String? _text;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final t = await AssetCacheService.loadString(widget.assetPath);
      if (!mounted) return;
      setState(() {
        _text = t;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hPad = EskoliaLayout.lessonHorizontalPadding(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: EskoliaAppBar.standard(context, title: widget.title),
      body: Stack(
        children: [
          const EskoliaAmbientBackground(),
          SafeArea(
            top: false,
            child: _error != null
                ? Padding(
                    padding: EdgeInsets.all(hPad),
                    child: Center(
                      child: Text(
                        '$_error',
                        style: TextStyle(color: Colors.red.shade200),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : _text == null
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: EskoliaVisual.neonCyan,
                        ),
                      )
                    : Scrollbar(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(
                            hPad,
                            12,
                            hPad,
                            EskoliaLayout.screenPaddingBottom,
                          ),
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: EskoliaLayout.lessonContentMaxWidth(
                                  context,
                                ),
                              ),
                              child: EskoliaCardContent(
                                padding: const EdgeInsets.fromLTRB(
                                  20,
                                  22,
                                  20,
                                  26,
                                ),
                                child: EskoliaLessonMarkdown(
                                  data: _text!,
                                  lessonAssetPath: widget.assetPath,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
