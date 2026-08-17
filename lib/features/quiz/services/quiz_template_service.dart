import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../core/services/eskolia_folder_service.dart';
import '../../../core/utils/eskolia_snackbar.dart';

/// Service pour generer et telecharger le modele / template officiel de quiz Eskolia (.json).
/// Ce fichier sert de reference aux apprenants et aux professeurs pour concevoir des quiz
/// exploitant les 5 types de questions interactives du moteur Eskolia.
class QuizTemplateService {
  QuizTemplateService._();

  static const String templateFilename = 'template_quiz_eskolia.json';

  /// Retourne le JSON du template avec des exemples commentes de chaque type.
  static String getQuizTemplateJson() {
    final Map<String, dynamic> template = {
      'quiz': {
        'title': 'Modèle de Quiz Eskolia — Tous Types',
        'description': 'Exemple complet intégrant les 5 types de questions : classique, séquence, association, diagnostic à indices et ticket.',
        'author': 'Professeur / Formateur Eskolia',
        'category': 'Systèmes & Réseaux'
      },
      'questions': [
        {
          'id': 'q_classic_1',
          'type': 'classic',
          'question': 'Quel rôle Windows Server fournit un annuaire centralisé et la gestion des identités ?',
          'answer': 'Active Directory Domain Services (AD DS)',
          'explanation': 'AD DS stocke les informations sur les objets du réseau (utilisateurs, ordinateurs, groupes) et gère l\'authentification via Kerberos/NTLM.',
          'difficulty': 'facile',
          'context': 'Windows Server · Active Directory'
        },
        {
          'id': 'q_seq_1',
          'type': 'sequence',
          'question': 'Remets dans l\'ordre chronologique les 4 étapes du processus d\'attribution DHCP (DORA) :',
          'answer': '1. Discover\n2. Offer\n3. Request\n4. Acknowledge',
          'items': [
            'DHCP Discover (le client cherche un serveur)',
            'DHCP Offer (le serveur propose une IP)',
            'DHCP Request (le client confirme la demande)',
            'DHCP Acknowledge (le serveur valide le bail)'
          ],
          'explanation': 'Le cycle DORA (Discover, Offer, Request, Acknowledge) s\'effectue en broadcast UDP ports 67 et 68.',
          'difficulty': 'moyen',
          'context': 'Réseau · Protocoles'
        },
        {
          'id': 'q_assoc_1',
          'type': 'association',
          'question': 'Associe chaque protocole réseau standard à son port TCP par défaut :',
          'answer': 'SSH -> 22, HTTP -> 80, HTTPS -> 443, RDP -> 3389',
          'pairs': [
            ['SSH', 'Port 22 (TCP)'],
            ['HTTP', 'Port 80 (TCP)'],
            ['HTTPS', 'Port 443 (TCP)'],
            ['RDP', 'Port 3389 (TCP)']
          ],
          'explanation': 'Ces ports standards IANA doivent être connus par cœur pour l\'administration réseau et la configuration de pare-feu.',
          'difficulty': 'facile',
          'context': 'Réseau · Ports & Services'
        },
        {
          'id': 'q_diag_1',
          'type': 'diagnostic_indices',
          'question': 'Un poste client n\'accède plus à Internet alors que les autres postes du même bureau fonctionnent. Quel est le diagnostic probable ?',
          'answer': 'Configuration IP incorrecte ou problème DHCP / carte réseau locale.',
          'indices': [
            'L\'adresse IP attribuée au poste commence par 169.254.x.x (APIPA).',
            'La passerelle par défaut n\'est pas joignable par ping.',
            'Le serveur DHCP n\'a pas répondu à la requête du client.'
          ],
          'explanation': 'Une adresse en 169.254.0.0/16 indique une défaillance de communication DHCP : le poste s\'est auto-attribué une adresse APIPA.',
          'difficulty': 'moyen',
          'context': 'Dépannage · Diagnostic Réseau'
        },
        {
          'id': 'q_ticket_1',
          'type': 'ticket',
          'question': 'Ticket #1042 : "Mon imprimante réseau n\'imprime plus depuis ce matin." Que dois-tu vérifier en priorité ?',
          'answer': 'Vérifier la connectivité réseau de l\'imprimante, l\'état de la file d\'impression et le spooler.',
          'checklist': [
            'Vérifier que l\'imprimante est allumée et connectée au réseau (ping IP).',
            'Vérifier l\'état du service Spouleur d\'impression (Spooler) sur le poste client.',
            'Vérifier s\'il y a un bourrage papier ou un travail bloqué dans la file d\'attente.',
            'Tester une page de test directement depuis l\'interface web de l\'imprimante.'
          ],
          'explanation': 'La démarche méthodique évite les réinstallations de pilotes inutiles avant d\'avoir contrôlé le statut matériel et réseau.',
          'difficulty': 'moyen',
          'context': 'Support Utilisateur · Périphériques'
        }
      ]
    };

    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(template);
  }

  /// Télécharge le fichier template pour l'utilisateur.
  static Future<void> downloadTemplate(BuildContext context) async {
    try {
      final jsonContent = getQuizTemplateJson();
      await EskoliaFolderService.instance.saveFile(
        EskoliaFolder.quiz,
        templateFilename,
        jsonContent,
        mimeType: 'application/json',
      );
      if (context.mounted) {
        showEskoliaSnackBar(
          context,
          'Template "$templateFilename" prêt et téléchargé !',
        );
      }
    } catch (e) {
      if (context.mounted) {
        showEskoliaSnackBar(
          context,
          'Erreur lors du téléchargement : $e',
        );
      }
    }
  }
}
