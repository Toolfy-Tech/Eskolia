import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/eskolia_layout.dart';
import '../../../core/theme/eskolia_visual.dart';
import '../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../shared/widgets/eskolia_shell_body.dart';
import '../../../shared/widgets/eskolia_app_bar.dart';
import '../data/question_report_entry.dart';
import '../data/question_report_repository.dart';

const Color _bg = EskoliaVisual.bgDeep;
const Color _violet = Color(0xFF6C63FF);
const Color _slate = Color(0xFF94A3B8);

String _statusLabel(String s) {
  switch (s) {
    case 'pending':
      return 'En attente';
    case 'in_progress':
      return 'En cours';
    case 'resolved':
      return 'Résolu';
    case 'rejected':
      return 'Refusé';
    default:
      return s;
  }
}

class LaboReportsScreen extends StatefulWidget {
  const LaboReportsScreen({super.key});

  @override
  State<LaboReportsScreen> createState() => _LaboReportsScreenState();
}

class _LaboReportsScreenState extends State<LaboReportsScreen> {
  final _repo = QuestionReportRepository();
  late Future<List<QuestionReportEntry>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    setState(() { _future = _repo.listMyReports(uid); });
  }

  Future<void> _onRefresh() async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final list = await _repo.listMyReports(uid);
    if (mounted) {
      setState(() => _future = Future.value(list));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: _bg,
      appBar: EskoliaAppBar.standard(context, title: 'Mes signalements'),
      body: Stack(
        children: [
          const EskoliaAmbientBackground(),
          EskoliaShellBody(
            safeAreaTop: false,
            child: FutureBuilder<List<QuestionReportEntry>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: _violet),
                  );
                }
                if (snap.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${snap.error}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: _slate),
                          ),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: _reload,
                            child: const Text('Réessayer'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                final list = snap.data ?? [];
                if (list.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Tu n’as pas encore envoyé de signalement.\n'
                        'Termine un quiz et utilise « Signaler » sur une question.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _slate.withValues(alpha: 0.9),
                          height: 1.4,
                        ),
                      ),
                    ),
                  );
                }
                return RefreshIndicator(
                  color: _violet,
                  onRefresh: _onRefresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      EskoliaLayout.screenPaddingH,
                      8,
                      EskoliaLayout.screenPaddingH,
                      EskoliaLayout.screenPaddingBottom,
                    ),
                    itemCount: list.length,
                    itemBuilder: (context, i) {
                      final e = list[i];
                      return _ReportTile(entry: e);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportTile extends StatelessWidget {
  const _ReportTile({required this.entry});

  final QuestionReportEntry entry;

  @override
  Widget build(BuildContext context) {
    final date = entry.createdAt;
    final dateStr = date == null
        ? '—'
        : '${date.day.toString().padLeft(2, '0')}/'
            '${date.month.toString().padLeft(2, '0')}/${date.year}';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  entry.kind.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _statusLabel(entry.status),
                  style: TextStyle(
                    color: _slate.withValues(alpha: 0.95),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (entry.questionPreview != null &&
              entry.questionPreview!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '« ${entry.questionPreview!} »',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _slate.withValues(alpha: 0.9),
                fontSize: 12,
                height: 1.3,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          if (entry.message.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              entry.message,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.75),
                fontSize: 12,
                height: 1.3,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            '$dateStr · ${entry.assetPath.isEmpty ? 'source inconnue' : entry.assetPath.split('/').last}',
            style: TextStyle(
              color: _slate.withValues(alpha: 0.55),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
