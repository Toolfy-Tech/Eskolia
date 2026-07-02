import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

IconData getIconDataForEmoji(String emoji) {
  // Supprimer les espaces et sélecteurs de variante s'il y en a
  final cleanEmoji = emoji.trim().replaceAll('\u{FE0F}', '');
  
  switch (cleanEmoji) {
    // Navigation / Sidebar
    case '🏠':
    case '\u{1F3E0}':
      return LucideIcons.home;
    case '📚':
    case '\u{1F4DA}':
      return LucideIcons.bookOpen;
    case '🎯':
    case '\u{1F3AF}':
      return LucideIcons.target;
    case '🛠️':
    case '🛠':
    case '\u{1F6E0}':
      return LucideIcons.wrench;
    case '🎮':
    case '\u{1F3AE}':
      return LucideIcons.gamepad2;
    case '🧠':
    case '\u{1F9E0}':
      return LucideIcons.brain;
    case '📝':
    case '\u{1F4DD}':
      return LucideIcons.fileText;
    case '📖':
    case '\u{1F4D6}':
      return LucideIcons.book;
    case '🏆':
    case '\u{1F3C6}':
      return LucideIcons.trophy;
    case '🎖️':
    case '🎖':
    case '\u{1F396}':
      return LucideIcons.medal;
    case '🧪':
    case '\u{1F9EA}':
      return LucideIcons.flaskConical;
    case '⚙️':
    case '⚙':
    case '\u{2699}':
      return LucideIcons.settings;
    case '🎓':
    case '\u{1F393}':
      return LucideIcons.graduationCap;
    case '🔥':
    case '\u{1F525}':
      return LucideIcons.flame;
      
    // Cartes & Thèmes
    case '💻':
    case 'it':
      return LucideIcons.laptop;
    case '🛡️':
    case '🛡':
    case '\u{1F6E1}':
    case 'security':
    case 'admin':
      return LucideIcons.shield;
    case '📡':
    case 'source':
      return LucideIcons.rss;
    case '🔌':
    case 'hardware':
      return LucideIcons.plug;
    case '💿':
    case 'software':
      return LucideIcons.disc;
    case '🚀':
      return LucideIcons.rocket;
    case '💡':
    case 'astuces':
      return LucideIcons.lightbulb;
    case '🖥️':
    case '🖥':
    case 'it_pro':
      return LucideIcons.monitor;
    case '❤️':
    case 'favoris':
      return LucideIcons.heart;
    case '🌟':
      return LucideIcons.star;
    case '🔍':
      return LucideIcons.search;
    case '📂':
      return LucideIcons.folderOpen;
    case '⚡':
      return LucideIcons.zap;
    case '🤖':
      return LucideIcons.bot;
    case '👋':
    case 'messages':
      return LucideIcons.messageSquare;
    case '🔀':
    case 'merge:':
      return LucideIcons.gitMerge;
    default:
      return LucideIcons.rss;
  }
}
