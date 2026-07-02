enum EskoliaFolder {
  quiz('Quiz'),
  flashcards('Flashcards'),
  cours('Cours'),
  bilans('Bilans'),
  profil('Profil');

  const EskoliaFolder(this.folderName);
  final String folderName;
}
