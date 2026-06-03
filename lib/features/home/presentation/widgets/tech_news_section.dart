import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../shared/widgets/eskolia_card.dart';
import '../../data/tech_news_models.dart';
import '../../data/tech_news_repository.dart';
import '../../../../core/constants/eskolia_tokens.dart';

const Color _slate = EskoliaTokens.textSecondary;
const Color _slateLight = EskoliaTokens.textSecondary;
const Color _cyan = EskoliaTokens.cyan;

/// Bloc veille RSS (dont sources pro Windows / infra) pour le hub accueil.
class TechNewsSection extends StatefulWidget {
  const TechNewsSection({super.key});

  @override
  State<TechNewsSection> createState() => _TechNewsSectionState();
}

class _TechNewsSectionState extends State<TechNewsSection> {
  final TechNewsRepository _repo = TechNewsRepository();

  bool _loading = true;
  String? _error;
  List<TechNewsItem> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await _repo.loadNews();
      if (!mounted) return;
      setState(() {
        _items = list;
        _loading = false;
        _error = list.isEmpty
            ? 'Aucun article pour le moment. Réessaie plus tard.'
            : null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Impossible de charger les flux. Vérifie ta connexion.';
      });
    }
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (!await canLaunchUrl(uri)) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return EskoliaCardContent(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text('\u{1F4F0}', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Veille IT pro',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Actualiser',
                onPressed: _loading ? null : _load,
                icon: _loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: _cyan,
                        ),
                      )
                    : Icon(
                        Icons.refresh_rounded,
                        color: _slateLight.withValues(alpha: 0.95),
                      ),
              ),
            ],
          ),
          Text(
            'Windows, AD, réseau, virtualisation… — flux RSS externes, ouverture dans le navigateur',
            style: TextStyle(
              color: _slate.withValues(alpha: 0.95),
              fontSize: 11,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          if (_loading && _items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: _cyan,
                  ),
                ),
              ),
            )
          else if (_error != null && _items.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _error!,
                    style: TextStyle(
                      color: _slateLight.withValues(alpha: 0.92),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: _load,
                    icon: const Icon(Icons.replay_rounded, color: _cyan),
                    label: const Text(
                      'Réessayer',
                      style: TextStyle(
                        color: _cyan,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _items.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: Colors.white.withValues(alpha: 0.06),
              ),
              itemBuilder: (context, index) {
                final item = _items[index];
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _openLink(item.link),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    height: 1.25,
                                  ),
                                ),
                                if (item.pubDate != null &&
                                    item.pubDate!.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    item.pubDate!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: _slate.withValues(alpha: 0.95),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  color: _cyan.withValues(alpha: 0.12),
                                  border: Border.all(
                                    color: _cyan.withValues(alpha: 0.35),
                                  ),
                                ),
                                child: Text(
                                  item.sourceLabel,
                                  style: const TextStyle(
                                    color: _cyan,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Icon(
                                Icons.open_in_new_rounded,
                                size: 16,
                                color: _slateLight.withValues(alpha: 0.75),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
