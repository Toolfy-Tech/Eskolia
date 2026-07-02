import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/optimus_content_models.dart';
import '../../../../core/constants/eskolia_tokens.dart';
import '../../../../shared/widgets/eskolia_video_overlay.dart';
import '../../../../shared/widgets/eskolia_article_overlay.dart';

const Color _violet = EskoliaTokens.violetSoft;
const Color _cyan = EskoliaTokens.cyan;
const Color _slate = EskoliaTokens.textSecondary;

class MediathequeSection extends StatefulWidget {
  const MediathequeSection({
    super.key,
    required this.specific,
    this.veille = const [],
    this.title = 'Ressources du module',
    this.initiallyExpanded = false,
  });

  final List<MediathequeItem> specific;
  final List<VeilleItem> veille;
  final String title;
  final bool initiallyExpanded;

  @override
  State<MediathequeSection> createState() => _MediathequeSectionState();
}

class _MediathequeSectionState extends State<MediathequeSection> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  int get _total => widget.specific.length + widget.veille.length;

  @override
  Widget build(BuildContext context) {
    if (_total == 0) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: _violet.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _violet.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: _expanded
                ? const BorderRadius.vertical(top: Radius.circular(14))
                : BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              child: Row(
                children: [
                  Icon(Icons.play_lesson_rounded,
                      color: _violet.withValues(alpha: 0.85), size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.95),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    '$_total lien${_total > 1 ? 's' : ''}',
                    style: TextStyle(color: _slate, fontSize: 12),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 240),
                    child: Icon(Icons.expand_more_rounded,
                        color: _slate, size: 20),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 240),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Divider(color: _violet.withValues(alpha: 0.18), height: 1),
                  if (widget.specific.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _SectionLabel(label: 'Ressources specifiques', color: _violet),
                    const SizedBox(height: 6),
                    ...widget.specific.map((e) => ResourceTileWidget(
                          title: e.title,
                          creator: e.creator,
                          description: '',
                          url: e.url,
                          accent: _violet,
                        )),
                  ],
                  if (widget.veille.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _SectionLabel(label: 'Annuaire de veille', color: _cyan),
                    const SizedBox(height: 6),
                    ...widget.veille.map((e) => ResourceTileWidget(
                          title: e.title,
                          creator: '',
                          description: e.description,
                          url: e.url,
                          accent: _cyan,
                        )),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: color.withValues(alpha: 0.85),
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class ResourceTileWidget extends StatelessWidget {
  const ResourceTileWidget({
    super.key,
    required this.title,
    required this.creator,
    required this.description,
    required this.url,
    required this.accent,
  });

  final String title;
  final String creator;
  final String description;
  final String url;
  final Color accent;

  String _getDomainName(String urlStr) {
    try {
      final uri = Uri.parse(urlStr);
      final host = uri.host.toLowerCase();
      var clean = host.startsWith('www.') ? host.substring(4) : host;
      if (clean.contains('youtube.com') || clean.contains('youtu.be')) return 'YouTube';
      if (clean.contains('it-connect.fr')) return 'IT-Connect';
      if (clean.contains('appvizer.fr')) return 'Appvizer';
      if (clean.contains('atlassian.com')) return 'Atlassian';
      if (clean.contains('github.com')) return 'GitHub';
      if (clean.contains('openclassrooms.com')) return 'OpenClassrooms';
      if (clean.contains('malekal.com')) return 'Malekal';
      if (clean.contains('justegeek.fr')) return 'JusteGeek';
      if (clean.contains('ecologie.gouv.fr')) return 'Ministère Écologie';
      if (clean.contains('cybermalveillance.gouv.fr')) return 'Cybermalveillance';
      if (clean.contains('notamax.fr')) return 'Notamax';
      if (clean.contains('microsoft.com')) {
        if (clean.contains('learn.')) return 'Microsoft Learn';
        if (clean.contains('support.')) return 'Support Microsoft';
        return 'Microsoft';
      }
      if (clean.contains('apple.com')) return 'Support Apple';
      if (clean.contains('secnumacademie.gouv.fr')) return 'SecNumAcadémie';
      if (clean.contains('cnil.fr')) return 'CNIL';
      if (clean.contains('zataz.com')) return 'ZATAZ';
      if (clean.contains('ubuntu-fr.org')) return 'Doc Ubuntu';
      if (clean.contains('netacad.com')) return 'Cisco NetAcad';

      // Capitalize first letter and strip TLD
      if (clean.contains('.')) {
        clean = clean.split('.')[0];
      }
      if (clean.isEmpty) return '';
      return clean.substring(0, 1).toUpperCase() + clean.substring(1);
    } catch (_) {
      return '';
    }
  }

  bool _isVideo(String urlStr) {
    final lower = urlStr.toLowerCase();
    return lower.contains('youtube.com') ||
        lower.contains('youtu.be') ||
        lower.contains('.mp4') ||
        lower.contains('vimeo.com');
  }

  bool _isPdf(String urlStr) {
    return urlStr.toLowerCase().endsWith('.pdf') ||
        urlStr.toLowerCase().contains('/pdf/') ||
        urlStr.toLowerCase().contains('.pdf?');
  }

  Color _getBrandColor(String domain) {
    final d = domain.toLowerCase();
    if (d.contains('youtube')) return const Color(0xFFFF4D4D); // Vibrant red
    if (d.contains('it-connect')) return const Color(0xFF9F7AEA); // Light purple
    if (d.contains('cisco') || d.contains('netacad')) return const Color(0xFF10B981); // Emerald
    if (d.contains('cnil')) return const Color(0xFF3B82F6); // Blue
    if (d.contains('microsoft')) return const Color(0xFF00E5FF); // Hyper cyan
    if (d.contains('apple')) return const Color(0xFF94A3B8); // Slate
    if (d.contains('atlassian')) return const Color(0xFF38BDF8); // Sky blue
    if (d.contains('github')) return const Color(0xFFE2E8F0); // Off-white
    if (d.contains('openclassrooms')) return const Color(0xFFED8936); // Orange
    if (d.contains('malekal')) return const Color(0xFF4FD1C5); // Teal
    if (d.contains('justegeek')) return const Color(0xFFF6AD55); // Orange
    if (d.contains('secnum')) return const Color(0xFF10B981); // Green
    if (d.contains('zataz')) return const Color(0xFFF87171); // Light red
    return EskoliaTokens.cyan;
  }

  @override
  Widget build(BuildContext context) {
    final isVid = _isVideo(url);
    final isPdf = _isPdf(url);
    final domain = _getDomainName(url);
    final brandColor = _getBrandColor(domain);

    // Dynamic type info
    final String typeText;
    final IconData typeIcon;
    final Color typeColor;

    if (isVid) {
      typeText = 'Vidéo';
      typeIcon = Icons.play_circle_fill_rounded;
      typeColor = EskoliaTokens.orange;
    } else if (isPdf) {
      typeText = 'Document PDF';
      typeIcon = Icons.picture_as_pdf_rounded;
      typeColor = EskoliaTokens.pink;
    } else {
      typeText = 'Article';
      typeIcon = Icons.article_rounded;
      typeColor = EskoliaTokens.cyan;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              final isYouTube = url.toLowerCase().contains('youtube.com') ||
                  url.toLowerCase().contains('youtu.be');
              if (isVid && isYouTube) {
                showEskoliaVideoOverlay(
                  context,
                  title: title,
                  url: url,
                );
              } else if (!isVid && !isPdf) {
                showEskoliaArticleOverlay(
                  context,
                  title: title,
                  url: url,
                );
              } else {
                launchUrl(
                  Uri.parse(url),
                  mode: LaunchMode.externalApplication,
                );
              }
            },
            splashColor: typeColor.withValues(alpha: 0.08),
            highlightColor: typeColor.withValues(alpha: 0.04),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon Container with glowing background
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: typeColor.withValues(alpha: 0.20),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        typeIcon,
                        size: 20,
                        color: typeColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Text & Badges content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            // Format Badge (Vidéo / Article / PDF)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: typeColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: typeColor.withValues(alpha: 0.25),
                                  width: 0.7,
                                ),
                              ),
                              child: Text(
                                typeText,
                                style: TextStyle(
                                  color: typeColor,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                            // Platform / Site Badge (e.g. sur YouTube, sur IT-Connect)
                            if (domain.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: brandColor.withValues(alpha: 0.10),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: brandColor.withValues(alpha: 0.20),
                                    width: 0.7,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.language_rounded,
                                      size: 10,
                                      color: brandColor,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      'sur $domain',
                                      style: TextStyle(
                                        color: brandColor,
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            // Creator/Author Label (e.g. par Tech2Tech)
                            if (creator.isNotEmpty &&
                                creator.toLowerCase() != domain.toLowerCase())
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.04),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.08),
                                    width: 0.7,
                                  ),
                                ),
                                child: Text(
                                  'par $creator',
                                  style: TextStyle(
                                    color: _slate.withValues(alpha: 0.95),
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (description.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            description,
                            style: TextStyle(
                              color: _slate.withValues(alpha: 0.90),
                              fontSize: 11.5,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Small trailing launch icon
                  Padding(
                    padding: const EdgeInsets.only(left: 8, top: 2),
                    child: Icon(
                      Icons.arrow_outward_rounded,
                      size: 14,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
