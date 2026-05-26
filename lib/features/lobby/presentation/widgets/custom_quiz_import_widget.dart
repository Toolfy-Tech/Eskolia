import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/services/asset_cache_service.dart';
import '../../../../core/services/eskolia_folder_service.dart';
import '../../../../core/utils/eskolia_snackbar.dart';
import '../../data/models/custom_quiz_data.dart';

const Color _slate = Color(0xFF94A3B8);
const Color _violet = Color(0xFF6C63FF);
const Color _green = Color(0xFF43E97B);
const Color _surface = Color(0xFF1E293B);

/// Widget autonome affiché dans le modal de création de lobby quand l'onglet
/// "Mon quiz" est actif. Gère téléchargement du template, import et preview.
class CustomQuizImportWidget extends StatefulWidget {
  const CustomQuizImportWidget({
    super.key,
    required this.onImported,
    this.importedData,
  });

  /// Appelé avec les données validées (ou null si reset).
  final ValueChanged<CustomQuizData?> onImported;

  /// Données déjà importées (persistées si l'utilisateur change d'onglet).
  final CustomQuizData? importedData;

  @override
  State<CustomQuizImportWidget> createState() => _CustomQuizImportWidgetState();
}

class _CustomQuizImportWidgetState extends State<CustomQuizImportWidget> {
  bool _downloading = false;
  bool _importing = false;

  Future<void> _downloadTemplate() async {
    if (_downloading) return;
    setState(() => _downloading = true);
    try {
      final raw = await AssetCacheService.loadString(
          'assets/templates/eskolia_quiz_template.json');
      if (kIsWeb) {
        await EskoliaFolderService.instance.saveFile(
          EskoliaFolder.quiz,
          'eskolia_quiz_template.json',
          raw,
          mimeType: 'application/json',
        );
      } else {
        await _shareMobile(raw);
      }
    } catch (e) {
      if (mounted) showEskoliaSnackBar(context, 'Erreur : impossible de charger le modèle.');
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  Future<void> _shareMobile(String content) async {
    // share_plus utilisé sur mobile — import conditionnel évité grâce à kIsWeb
    // La méthode n'est jamais appelée sur web.
    if (mounted) {
      showEskoliaSnackBar(context, 'Modèle copié — collez-le dans un fichier .json');
      await Clipboard.setData(ClipboardData(text: content));
    }
  }

  Future<void> _importFile() async {
    if (_importing) return;
    setState(() => _importing = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final bytes = result.files.first.bytes;
      if (bytes == null) {
        if (mounted) showEskoliaSnackBar(context, 'Impossible de lire le fichier.');
        return;
      }

      final jsonString = utf8.decode(bytes);
      final data = CustomQuizData.fromJsonString(jsonString);

      if (mounted) {
        widget.onImported(data);
        showEskoliaSnackBar(context,
            '${data.questions.length} questions importées — "${data.title}"');
      }
    } on FormatException catch (e) {
      if (mounted) showEskoliaSnackBar(context, 'Format invalide : ${e.message}');
    } catch (e) {
      if (mounted) showEskoliaSnackBar(context, 'Erreur lors de l\'import.');
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.importedData;
    return data != null ? _buildPreview(data) : _buildImportButtons();
  }

  Widget _buildImportButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          onPressed: _downloading ? null : _downloadTemplate,
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          icon: _downloading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: _slate),
                )
              : const Icon(Icons.download_rounded, size: 18),
          label: const Text('Télécharger le modèle .json'),
        ),
        const SizedBox(height: 10),
        FilledButton.icon(
          onPressed: _importing ? null : _importFile,
          style: FilledButton.styleFrom(
            backgroundColor: _violet,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          icon: _importing
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.folder_open_rounded, size: 18),
          label: const Text('Importer mon quiz .json'),
        ),
        const SizedBox(height: 10),
        Text(
          'Téléchargez le modèle, remplissez-le avec vos questions, puis importez-le ici.',
          style: TextStyle(
            color: _slate.withValues(alpha: 0.8),
            fontSize: 11,
            height: 1.35,
          ),
        ),
      ],
    );
  }

  Widget _buildPreview(CustomQuizData data) {
    final preview = data.questions.take(3).toList();
    final remaining = data.questions.length - preview.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header succès
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _green.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _green.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: _green, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '"${data.title}"',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      '${data.questions.length} questions · par ${data.author}',
                      style: TextStyle(color: _slate, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Aperçu questions
        Text(
          'Aperçu',
          style: TextStyle(color: _slate, fontSize: 11, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < preview.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Q${i + 1} ',
                        style: TextStyle(
                          color: _violet,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          preview[i].question,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (remaining > 0)
                Text(
                  '+ $remaining autre${remaining > 1 ? 's' : ''} question${remaining > 1 ? 's' : ''}',
                  style: TextStyle(color: _slate, fontSize: 11),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Reset
        TextButton.icon(
          onPressed: () => widget.onImported(null),
          style: TextButton.styleFrom(foregroundColor: _slate),
          icon: const Icon(Icons.refresh_rounded, size: 16),
          label: const Text('Changer de fichier'),
        ),
      ],
    );
  }
}
