import 'package:web/web.dart' as web;

web.AudioContext? _context;

/// Deux bips (la, ré) de 150 ms ; le navigateur l'autorise une fois que la page a reçu un geste de l'utilisateur.
void playAlertSound() {
  final context = _context ??= web.AudioContext();
  for (final (index, frequency) in const [(0, 880.0), (1, 1175.0)]) {
    final oscillator = context.createOscillator();
    final gain = context.createGain();
    oscillator.frequency.value = frequency;
    gain.gain.value = 0.2;
    oscillator.connect(gain);
    gain.connect(context.destination);
    final start = context.currentTime + index * 0.2;
    oscillator.start(start);
    oscillator.stop(start + 0.15);
  }
}
