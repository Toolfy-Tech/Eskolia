import 'dart:math' show Random;
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/optimus_content_models.dart';
import '../../../../core/constants/eskolia_tokens.dart';
import '../../../../core/theme/eskolia_visual.dart';
import 'support_media.dart';

const Color _orange = EskoliaTokens.orange;
const Color _slate  = EskoliaTokens.textSecondary;

/// Ouvre le bon viewer selon le type :
/// image → plein écran inline, PDF/vidéo → overlay dédié.
void openSupportItem(BuildContext context, SupportItem item) {
  if (item.type == 'image') {
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) =>
            _FullscreenImageViewer(url: item.url, title: item.title),
      ),
    );
  } else {
    showSupportViewer(context, [item]);
  }
}

/// Ouvre l'overlay de tous les supports en un tap.
void showSupportViewer(BuildContext context, List<SupportItem> items) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _SupportViewerSheet(items: items, parentContext: context),
  );
}

/// Bouton pill flottant — à placer via [Positioned] dans un [Stack].
class SupportViewerFab extends StatelessWidget {
  const SupportViewerFab({super.key, required this.items});

  final List<SupportItem> items;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(28),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => showSupportViewer(context, items),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _orange.withValues(alpha: 0.95),
                EskoliaTokens.amber.withValues(alpha: 0.90),
              ],
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: _orange.withValues(alpha: 0.45),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.school_rounded, color: Colors.white, size: 17),
                const SizedBox(width: 8),
                Text(
                  'Supports · ${items.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Overlay
// ─────────────────────────────────────────────────────────────────────────────

class _SupportViewerSheet extends StatelessWidget {
  const _SupportViewerSheet({
    required this.items,
    required this.parentContext,
  });

  final List<SupportItem> items;
  final BuildContext parentContext;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.35,
      maxChildSize: 0.95,
      builder: (ctx, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: EskoliaVisual.bgDeep,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          border: Border(
            top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 8, 0),
              child: Row(
                children: [
                  Icon(Icons.school_rounded,
                      color: _orange.withValues(alpha: 0.9), size: 20),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Supports de cours',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close_rounded, color: _slate, size: 22),
                  ),
                ],
              ),
            ),
            Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),
            Expanded(
              child: ListView.separated(
                controller: scrollCtrl,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 48),
                itemCount: items.length,
                separatorBuilder: (_, __) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Divider(
                      color: Colors.white.withValues(alpha: 0.06), height: 1),
                ),
                itemBuilder: (ctx2, i) => _SupportViewerItem(
                  item: items[i],
                  onImageTap: () => _pushFullscreen(context, items[i]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _pushFullscreen(BuildContext ctx, SupportItem item) {
    Navigator.of(ctx).push<void>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) =>
            _FullscreenImageViewer(url: item.url, title: item.title),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _SupportViewerItem extends StatelessWidget {
  const _SupportViewerItem({
    required this.item,
    required this.onImageTap,
  });

  final SupportItem item;
  final VoidCallback onImageTap;

  static Color _colorFor(String type) => switch (type) {
        'pdf'   => EskoliaTokens.error,
        'video' => EskoliaTokens.info,
        _       => _orange,
      };
  static IconData _iconFor(String type) => switch (type) {
        'pdf'   => Icons.picture_as_pdf_rounded,
        'video' => Icons.play_circle_rounded,
        _       => Icons.image_rounded,
      };
  static String _labelFor(String type) => switch (type) {
        'pdf'   => 'PDF',
        'video' => 'Vidéo',
        _       => 'Image',
      };

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(item.type);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_iconFor(item.type), size: 12, color: color),
                  const SizedBox(width: 4),
                  Text(
                    _labelFor(item.type),
                    style: TextStyle(
                        color: color,
                        fontSize: 10,
                        fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  if (item.description.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(
                        item.description,
                        style: TextStyle(
                          color: _slate.withValues(alpha: 0.85),
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (item.type == 'image')
          _InlineImage(url: item.url, onTap: onImageTap)
        else
          _MediaViewer(item: item),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _InlineImage extends StatelessWidget {
  const _InlineImage({required this.url, required this.onTap});

  final String url;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              url,
              fit: BoxFit.contain,
              loadingBuilder: (_, child, progress) {
                if (progress == null) return child;
                return _placeholder(
                  CircularProgressIndicator(
                    value: progress.expectedTotalBytes != null
                        ? progress.cumulativeBytesLoaded /
                            progress.expectedTotalBytes!
                        : null,
                    color: _orange,
                    strokeWidth: 2,
                  ),
                );
              },
              errorBuilder: (_, __, ___) => _placeholder(
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.broken_image_rounded,
                        color: _slate, size: 22),
                    const SizedBox(width: 8),
                    Text('Image indisponible',
                        style: TextStyle(color: _slate, fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
          // Hint plein écran
          Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.fullscreen_rounded,
                color: Colors.white70, size: 16),
          ),
        ],
      ),
    );
  }

  Widget _placeholder(Widget child) => Container(
        height: 140,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
        ),
        child: child,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Chargeur + viewer inline pour PDF et vidéo
// ─────────────────────────────────────────────────────────────────────────────

enum _LoadState { idle, loading, loaded, error }

class _MediaViewer extends StatefulWidget {
  const _MediaViewer({required this.item});

  final SupportItem item;

  @override
  State<_MediaViewer> createState() => _MediaViewerState();
}

class _MediaViewerState extends State<_MediaViewer> {
  static final _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(minutes: 5),
  ));

  _LoadState _state = _LoadState.idle;
  double? _progress;
  String? _blobUrl;
  // Chaque instance a un viewId unique pour platformViewRegistry.
  final String _viewId =
      'eskolia-media-${Random().nextInt(999999999)}';

  @override
  void dispose() {
    if (_blobUrl != null) revokeBlobUrl(_blobUrl!);
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _state = _LoadState.loading;
      _progress = null;
    });
    try {
      final resp = await _dio.get<List<int>>(
        widget.item.url,
        options: Options(responseType: ResponseType.bytes),
        onReceiveProgress: (received, total) {
          if (total > 0 && mounted) {
            setState(() => _progress = received / total);
          }
        },
      );
      final bytes = Uint8List.fromList(resp.data!);
      final mimeType =
          widget.item.type == 'pdf' ? 'application/pdf' : 'video/mp4';
      final url = createBlobUrl(bytes, mimeType);
      if (mounted) {
        setState(() {
          _blobUrl = url;
          _state = _LoadState.loaded;
        });
      }
    } catch (e) {
      debugPrint('[SupportViewer._load] $e url=${widget.item.url}');
      if (mounted) setState(() => _state = _LoadState.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return switch (_state) {
      _LoadState.idle    => _buildIdleButton(),
      _LoadState.loading => _buildProgress(),
      _LoadState.loaded  => _buildViewer(),
      _LoadState.error   => _buildError(),
    };
  }

  Widget _buildIdleButton() {
    final isPdf = widget.item.type == 'pdf';
    final color = isPdf ? EskoliaTokens.error : EskoliaTokens.info;
    final icon  = isPdf
        ? Icons.picture_as_pdf_rounded
        : Icons.play_circle_filled_rounded;
    final label = isPdf ? 'Afficher le PDF' : 'Lire la vidéo';
    return FilledButton.icon(
      onPressed: kIsWeb
          ? _load
          : () => launchUrl(Uri.parse(widget.item.url),
              mode: LaunchMode.externalApplication),
      icon: Icon(icon, size: 17),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.15),
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 13),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
      ),
    );
  }

  Widget _buildProgress() {
    final isPdf = widget.item.type == 'pdf';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isPdf ? 'Chargement du PDF...' : 'Chargement de la vidéo...',
            style: TextStyle(color: _slate, fontSize: 12),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _progress,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              color: _orange,
              minHeight: 4,
            ),
          ),
          if (_progress != null) ...[
            const SizedBox(height: 6),
            Text(
              '${(_progress! * 100).toStringAsFixed(0)} %',
              style: TextStyle(color: _slate, fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildViewer() {
    if (_blobUrl == null) return _buildIdleButton();
    final isPdf  = widget.item.type == 'pdf';
    final height = isPdf ? 540.0 : 260.0;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: height,
        child: isPdf
            ? buildPdfViewer(_blobUrl!, _viewId)
            : buildVideoViewer(_blobUrl!, _viewId),
      ),
    );
  }

  Widget _buildError() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: EskoliaTokens.error.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            'Chargement impossible — verifie ta connexion.',
            style: TextStyle(
                color: EskoliaTokens.error.withValues(alpha: 0.85),
                fontSize: 12),
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => launchUrl(Uri.parse(widget.item.url),
              mode: LaunchMode.externalApplication),
          icon: const Icon(Icons.open_in_new_rounded, size: 15),
          label: Text(widget.item.type == 'pdf'
              ? 'Ouvrir dans le navigateur'
              : 'Voir la vidéo'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white60,
            side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Visionneuse plein écran avec zoom
// ─────────────────────────────────────────────────────────────────────────────

class _FullscreenImageViewer extends StatelessWidget {
  const _FullscreenImageViewer({required this.url, required this.title});

  final String url;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        elevation: 0,
      ),
      body: InteractiveViewer(
        maxScale: 6.0,
        minScale: 0.5,
        child: Center(
          child: Image.network(
            url,
            fit: BoxFit.contain,
            loadingBuilder: (_, child, progress) {
              if (progress == null) return child;
              return const Center(
                child: CircularProgressIndicator(
                    color: Colors.white54, strokeWidth: 2),
              );
            },
            errorBuilder: (_, __, ___) => Icon(
              Icons.broken_image_rounded,
              color: Colors.white24,
              size: 48,
            ),
          ),
        ),
      ),
    );
  }
}
