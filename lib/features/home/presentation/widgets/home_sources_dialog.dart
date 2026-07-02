import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/eskolia_tokens.dart';
import '../providers/home_providers.dart';

void showHomeSourcesDialog(BuildContext context, WidgetRef ref) {
  final labelController = TextEditingController();
  final urlController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  
  bool showTuto = true; // Variable d'état initiale pour le tutoriel

  showDialog<void>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Consumer(
            builder: (context, ref, _) {
              final activeSubs = ref.watch(homeSubscribedSourcesProvider);
              final customSubs = activeSubs.where((s) => s.startsWith('custom:')).toList();

              // Sources prédéfinies dures
              final predefined = [
                {'id': 'it_connect', 'label': 'IT-Connect', 'desc': 'Administration système et réseau'},
                {'id': 'le_crabe_info', 'label': 'Le Crabe Info', 'desc': 'Tutoriels, actualités hardware et OS'},
                {'id': 'malekal', 'label': 'Malekal', 'desc': 'Sécurité informatique et désinfection'},
                {'id': 'cert_fr', 'label': 'CERT-FR', 'desc': 'Alertes de sécurité de l\'ANSSI'},
                {'id': 'zataz', 'label': 'Zataz', 'desc': 'Actualités sur la cybersécurité et les fuites de données'},
                {'id': 'tech2tech', 'label': 'Tech2Tech', 'desc': 'Actualités et astuces pour techniciens IT'},
                {'id': 'rdr_it', 'label': 'RDR-IT', 'desc': 'Tutoriels SysAdmin et Cloud'},
                {'id': 'syskb', 'label': 'SysKB', 'desc': 'Actualités et astuces Windows / Linux'},
              ];

              Widget bodyContent;
              if (showTuto) {
                bodyContent = Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.menu_book_rounded, color: EskoliaTokens.cyan, size: 24),
                            const SizedBox(width: 10),
                            Text(
                              'Tutoriel : Gérer vos flux RSS',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close_rounded, color: Colors.white60),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildTutoStep(
                              '1',
                              'Sources Eskolia',
                              'Activez ou désactivez les flux recommandés (IT-Connect, Le Crabe Info, CERT-FR...) d\'un simple commutateur.',
                            ),
                            const SizedBox(height: 12),
                            _buildTutoStep(
                              '2',
                              'Sources Perso (RSS)',
                              'Ajoutez n\'importe quel site disposant d\'un flux RSS. Saisissez un nom et son URL pour générer une carte de veille dédiée sur votre écran d\'accueil.',
                            ),
                            const SizedBox(height: 12),
                            _buildTutoStep(
                              '3',
                              'Comment trouver une URL RSS ?',
                              '• Cherchez le symbole RSS orange 🍊 sur vos sites favoris.\n• Ajoutez "/feed/" ou "/rss/" à la fin de l\'URL du site (ex: https://site.com/feed/).\n• Tapez sur Google : "[Nom du site] flux RSS".',
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: EskoliaTokens.cyan.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: EskoliaTokens.cyan.withValues(alpha: 0.2)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.flash_on_rounded, color: EskoliaTokens.cyan, size: 16),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Exemples prêts à tester (cliquez pour remplir) :',
                                        style: GoogleFonts.outfit(color: EskoliaTokens.cyan, fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  _buildExampleItem(
                                    'Le Monde (Actualités)',
                                    'https://www.lemonde.fr/rss/une.xml',
                                    labelController,
                                    urlController,
                                    () => setState(() => showTuto = false),
                                  ),
                                  const SizedBox(height: 4),
                                  _buildExampleItem(
                                    'Next (Actu Tech)',
                                    'https://www.next.ink/feed/',
                                    labelController,
                                    urlController,
                                    () => setState(() => showTuto = false),
                                  ),
                                  const SizedBox(height: 4),
                                  _buildExampleItem(
                                    'Frandroid (Mobiles/Tech)',
                                    'https://www.frandroid.com/feed',
                                    labelController,
                                    urlController,
                                    () => setState(() => showTuto = false),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() => showTuto = false);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: EskoliaTokens.cyan,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'Compris, configurer mes flux !',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ],
                );
              } else {
                bodyContent = Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Gérer vos flux de veille',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () => setState(() => showTuto = true),
                              icon: const Icon(Icons.help_outline_rounded, color: EskoliaTokens.cyan, size: 20),
                              tooltip: 'Afficher le tutoriel',
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close_rounded, color: Colors.white60),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: DefaultTabController(
                        length: 3,
                        child: Column(
                          children: [
                            TabBar(
                              labelColor: EskoliaTokens.cyan,
                              unselectedLabelColor: Colors.white60,
                              indicatorColor: EskoliaTokens.cyan,
                              labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                              tabs: const [
                                Tab(text: 'Sources Eskolia'),
                                Tab(text: 'Sources perso'),
                                Tab(text: 'Fonctionnalités'),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: TabBarView(
                                children: [
                                  // Onglet 1 : Sources prédéfinies
                                  ListView.separated(
                                    itemCount: predefined.length,
                                    separatorBuilder: (_, __) => const Divider(color: Colors.white10, height: 1),
                                    itemBuilder: (context, idx) {
                                      final item = predefined[idx];
                                      final id = item['id']!;
                                      final label = item['label']!;
                                      final desc = item['desc']!;
                                      
                                      final isActive = activeSubs.contains(label);
                                      
                                      return SwitchListTile(
                                        title: Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                                        subtitle: Text(desc, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                                        value: isActive,
                                        activeColor: EskoliaTokens.cyan,
                                        onChanged: (val) {
                                          final notifier = ref.read(homeSubscribedSourcesProvider.notifier);
                                          if (val) {
                                            notifier.subscribe(label);
                                          } else {
                                            notifier.unsubscribe(label);
                                          }
                                        },
                                      );
                                    },
                                  ),
                                  // Onglet 2 : Sources personnalisées
                                  SingleChildScrollView(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 4),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          Form(
                                            key: formKey,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.stretch,
                                              children: [
                                                Text(
                                                  'Ajouter un flux RSS personnalisé',
                                                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                                                ),
                                                const SizedBox(height: 12),
                                                TextFormField(
                                                  controller: labelController,
                                                  style: const TextStyle(color: Colors.white, fontSize: 13),
                                                  decoration: InputDecoration(
                                                    labelText: 'Nom du flux',
                                                    labelStyle: const TextStyle(color: Colors.white60, fontSize: 12),
                                                    enabledBorder: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(10),
                                                      borderSide: const BorderSide(color: Colors.white12),
                                                    ),
                                                    focusedBorder: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(10),
                                                      borderSide: const BorderSide(color: EskoliaTokens.cyan),
                                                    ),
                                                  ),
                                                  validator: (val) => val == null || val.trim().isEmpty ? 'Requis' : null,
                                                ),
                                                const SizedBox(height: 12),
                                                TextFormField(
                                                  controller: urlController,
                                                  style: const TextStyle(color: Colors.white, fontSize: 13),
                                                  decoration: InputDecoration(
                                                    labelText: 'URL du flux RSS (ex: https://...)',
                                                    labelStyle: const TextStyle(color: Colors.white60, fontSize: 12),
                                                    enabledBorder: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(10),
                                                      borderSide: const BorderSide(color: Colors.white12),
                                                    ),
                                                    focusedBorder: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(10),
                                                      borderSide: const BorderSide(color: EskoliaTokens.cyan),
                                                    ),
                                                  ),
                                                  validator: (val) {
                                                    if (val == null || val.trim().isEmpty) return 'Requis';
                                                    if (!val.startsWith('http://') && !val.startsWith('https://')) {
                                                      return 'L\'URL doit commencer par http:// ou https://';
                                                    }
                                                    return null;
                                                  },
                                                ),
                                                const SizedBox(height: 14),
                                                ElevatedButton.icon(
                                                  onPressed: () {
                                                    if (formKey.currentState?.validate() == true) {
                                                      final label = labelController.text.trim();
                                                      final url = urlController.text.trim();
                                                      
                                                      final customSourceVal = 'custom:${jsonEncode({
                                                        'label': label,
                                                        'rssUrl': url,
                                                        'category': 'it_pro',
                                                      })}';
                                                      
                                                      ref.read(homeSubscribedSourcesProvider.notifier).subscribe(customSourceVal);
                                                      
                                                      labelController.clear();
                                                      urlController.clear();
                                                    }
                                                  },
                                                  icon: const Icon(Icons.add_rounded, size: 18),
                                                  label: const Text('Ajouter la source', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: EskoliaTokens.cyan,
                                                    foregroundColor: Colors.black,
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 24),
                                          Text(
                                            'Vos flux personnalisés (${customSubs.length})',
                                            style: GoogleFonts.outfit(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 8),
                                          if (customSubs.isEmpty)
                                            const Padding(
                                              padding: EdgeInsets.symmetric(vertical: 20),
                                              child: Text(
                                                'Aucun flux personnalisé pour le moment.',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(color: Colors.white30, fontSize: 12),
                                              ),
                                            )
                                          else
                                            ListView.separated(
                                              shrinkWrap: true,
                                              physics: const NeverScrollableScrollPhysics(),
                                              itemCount: customSubs.length,
                                              separatorBuilder: (_, __) => const SizedBox(height: 8),
                                              itemBuilder: (context, idx) {
                                                final rawSub = customSubs[idx];
                                                String label = 'Flux perso';
                                                String url = '';
                                                try {
                                                  final map = jsonDecode(rawSub.substring(7)) as Map<String, dynamic>;
                                                  label = map['label'] as String? ?? 'Flux perso';
                                                  url = map['rssUrl'] as String? ?? '';
                                                } catch (_) {}
                                                
                                                return Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white.withValues(alpha: 0.03),
                                                    borderRadius: BorderRadius.circular(10),
                                                    border: Border.all(color: Colors.white10),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(label, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                                                            const SizedBox(height: 2),
                                                            Text(url, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white38, fontSize: 10)),
                                                          ],
                                                        ),
                                                      ),
                                                      IconButton(
                                                        onPressed: () {
                                                          ref.read(homeSubscribedSourcesProvider.notifier).unsubscribe(rawSub);
                                                        },
                                                        icon: const Icon(Icons.delete_outline_rounded, color: EskoliaTokens.error, size: 18),
                                                        tooltip: 'Supprimer ce flux',
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Onglet 3 : Fonctionnalités
                                  Consumer(
                                    builder: (context, ref, _) {
                                      final order = ref.watch(homeCardsOrderProvider);
                                      final features = [
                                        {'key': 'feature:ai', 'label': 'Mon Tuteur IA (Optimus)', 'desc': 'Accès rapide au tuteur virtuel et entraînements', 'icon': Icons.psychology_rounded},
                                        {'key': 'feature:solo', 'label': 'Mode Solo (Quiz)', 'desc': 'Lancez des séries de quiz (Survival, Vrai/Faux, Maîtrise)', 'icon': Icons.sports_esports_rounded},
                                        {'key': 'feature:classement', 'label': 'Mon Rang & XP', 'desc': 'Suivi en temps réel de votre niveau et de la ligue hebdomadaire', 'icon': Icons.emoji_events_rounded},
                                        {'key': 'feature:tp', 'label': 'Travaux Pratiques (TP)', 'desc': 'Simulation de pannes réseau, PowerShell, Active Directory', 'icon': Icons.construction_rounded},
                                        {'key': 'feature:notebook', 'label': 'Bloc-notes Markdown', 'desc': 'Prise de notes de cours et génération de QCM par l\'IA', 'icon': Icons.note_alt_rounded},
                                        {'key': 'feature:flashcards', 'label': 'Flashcards', 'desc': 'Révision rapide par cartes mémoires actives', 'icon': Icons.bolt_rounded},
                                        {'key': 'feature:docs', 'label': 'Documentation & Mémos', 'desc': 'Accès aux fiches mémo (OSI, ITIL, ANSSI, RGPD)', 'icon': Icons.menu_book_rounded},
                                        {'key': 'feature:labo', 'label': 'Le Labo (Quiz Maker)', 'desc': 'Proposez vos propres questions et contribuez à la base', 'icon': Icons.science_rounded},
                                        {'key': 'feature:lobbys', 'label': 'Lobbys Multijoueur', 'desc': 'Rejoignez ou créez un salon de jeu en direct', 'icon': Icons.groups_rounded},
                                      ];

                                      return ListView.separated(
                                        itemCount: features.length,
                                        separatorBuilder: (_, __) => const Divider(color: Colors.white10, height: 1),
                                        itemBuilder: (context, idx) {
                                          final f = features[idx];
                                          final key = f['key'] as String;
                                          final label = f['label'] as String;
                                          final desc = f['desc'] as String;
                                          final icon = f['icon'] as IconData;

                                          final isActive = order.contains(key);

                                          return SwitchListTile(
                                            title: Row(
                                              children: [
                                                Icon(icon, color: EskoliaTokens.cyan, size: 18),
                                                const SizedBox(width: 8),
                                                Text(label, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                                              ],
                                            ),
                                            subtitle: Text(desc, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                                            value: isActive,
                                            activeColor: EskoliaTokens.cyan,
                                            onChanged: (val) {
                                              final notifier = ref.read(homeCardsOrderProvider.notifier);
                                              if (val) {
                                                notifier.addCard(key);
                                              } else {
                                                notifier.removeCard(key);
                                              }
                                            },
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }

              return Dialog(
                backgroundColor: EskoliaTokens.surface1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: Colors.white12, width: 1.5),
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: bodyContent,
                  ),
                ),
              );
            },
          );
        },
      );
    },
  );
}

Widget _buildTutoStep(String number, String title, String body) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: EskoliaTokens.cyan.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: EskoliaTokens.cyan.withValues(alpha: 0.3)),
        ),
        child: Text(
          number,
          style: GoogleFonts.outfit(color: EskoliaTokens.cyan, fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ),
      const SizedBox(width: 14),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              body,
              style: const TextStyle(color: Colors.white60, fontSize: 12, height: 1.35),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _buildExampleItem(
  String name,
  String url,
  TextEditingController labelCtrl,
  TextEditingController urlCtrl,
  VoidCallback onCloseTuto,
) {
  return InkWell(
    onTap: () {
      labelCtrl.text = name;
      urlCtrl.text = url;
      onCloseTuto();
    },
    borderRadius: BorderRadius.circular(6),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                Text(url, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white38, fontSize: 9)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: const [
                Icon(Icons.edit_note_rounded, color: EskoliaTokens.cyan, size: 12),
                SizedBox(width: 2),
                Text('Tester', style: TextStyle(color: EskoliaTokens.cyan, fontSize: 9, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
