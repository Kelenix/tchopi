/// Texte comparable sans accents ni casse (« Béoumi » ≈ « beoumi »), pour les recherches.
String foldAccents(String text) {
  const from = 'àâäáãåçéèêëíìîïñóòôöõúùûüÿœ’';
  const to = 'aaaaaaceeeeiiiinooooouuuuyo\'';
  final lower = text.toLowerCase();
  final out = StringBuffer();
  for (final char in lower.split('')) {
    final i = from.indexOf(char);
    out.write(i < 0 ? char : to[i]);
  }
  return out.toString();
}
