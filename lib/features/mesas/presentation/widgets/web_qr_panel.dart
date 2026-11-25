import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:screen_brightness/screen_brightness.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Dirección pública de la web de resultados (la misma que codifica el QR
/// de `assets/images/qr.png`).
const String kWebResultsUrl = 'torneo-web-mikido.vercel.app';

/// Panel "Escanea el QR" con la identidad de la llave de eliminación:
/// logo + palabra MIKIDO, línea roja, tarjeta del tema y el QR enmarcado
/// con conectores grises y nodos rojos (como las líneas de la llave).
/// Respeta el tema claro/oscuro.
///
/// [horizontal] = escritorio (texto a la izquierda, QR grande a la
/// derecha); si no, vertical (pop-up en celular).
class WebQrPanel extends StatelessWidget {
  final bool horizontal;

  const WebQrPanel({super.key, this.horizontal = false});

  @override
  Widget build(BuildContext context) {
    final qr = _FramedQr(size: horizontal ? 210 : 230);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(18),
      child: horizontal
          ? Row(
              children: [
                Expanded(child: _Info(alignStart: true)),
                const SizedBox(width: 16),
                qr,
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Info(alignStart: false),
                const SizedBox(height: 18),
                qr,
              ],
            ),
    );
  }
}

/// Logo, línea roja y texto (mismo encabezado que la llave).
class _Info extends StatelessWidget {
  final bool alignStart;
  const _Info({required this.alignStart});

  @override
  Widget build(BuildContext context) {
    final align =
        alignStart ? CrossAxisAlignment.start : CrossAxisAlignment.center;
    final textAlign = alignStart ? TextAlign.start : TextAlign.center;
    return Column(
      crossAxisAlignment: align,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/icon/icon.png', height: 36),
            const SizedBox(width: 10),
            Image.asset('assets/images/mikido_wordmark.png', height: 28),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          height: 2,
          width: alignStart ? 150 : 180,
          color: AppColors.primary,
        ),
        const SizedBox(height: 12),
        Text(
          'ESCANEA EL QR',
          textAlign: textAlign,
          style: AppTextStyles.titleLarge.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        Text(
          'y consulta los resultados',
          textAlign: textAlign,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey400),
        ),
        Text(
          'EN TIEMPO REAL',
          textAlign: textAlign,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          kWebResultsUrl,
          textAlign: textAlign,
          style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey400),
        ),
      ],
    );
  }
}

/// QR sobre fondo blanco, enmarcado con conectores como los de la llave.
class _FramedQr extends StatelessWidget {
  final double size;
  const _FramedQr({required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _BracketFramePainter(lineColor: AppColors.grey600),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Container(
          width: size,
          height: size,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.primary, width: 1.5),
          ),
          child: Image.asset('assets/images/qr.png', fit: BoxFit.contain),
        ),
      ),
    );
  }
}

/// Esquinas en L con líneas grises y nodos rojos en las esquinas y a mitad
/// de los lados: el mismo lenguaje que los conectores de la llave.
class _BracketFramePainter extends CustomPainter {
  final Color lineColor;
  const _BracketFramePainter({required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = lineColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final dot = Paint()..color = AppColors.primary;
    const arm = 24.0;
    const inset = 2.0;
    final w = size.width, h = size.height;

    void corner(double x, double y, double dx, double dy) {
      canvas.drawPath(
          Path()
            ..moveTo(x + dx * arm, y)
            ..lineTo(x, y)
            ..lineTo(x, y + dy * arm),
          line);
      canvas.drawCircle(Offset(x, y), 3.5, dot);
    }

    corner(inset, inset, 1, 1);
    corner(w - inset, inset, -1, 1);
    corner(inset, h - inset, 1, -1);
    corner(w - inset, h - inset, -1, -1);

    // Nodo a mitad de cada lado lateral, como la unión de dos partidos.
    for (final x in [inset, w - inset]) {
      canvas.drawLine(Offset(x, h / 2 - 14), Offset(x, h / 2 + 14), line);
      canvas.drawCircle(Offset(x, h / 2), 3.5, dot);
    }
  }

  @override
  bool shouldRepaint(covariant _BracketFramePainter oldDelegate) =>
      oldDelegate.lineColor != lineColor;
}

/// Pop-up del botón QR (pantalla Mesas y Mesa en vivo en celular): usa el
/// póster oscuro [WebQrPoster]. El panel de escritorio sigue siendo
/// [WebQrPanel].
Future<void> showWebQrDialog(BuildContext context) async {
  // En celular, brillo al máximo mientras se muestra el QR (se lee mejor
  // al escanearlo). Solo el brillo de la app: al cerrar vuelve solo.
  final isPhone = !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  if (isPhone) {
    try {
      await ScreenBrightness.instance.setApplicationScreenBrightness(1.0);
    } catch (_) {}
  }
  if (!context.mounted) return;
  try {
    await _showWebQrDialogRaw(context);
  } finally {
    if (isPhone) {
      try {
        await ScreenBrightness.instance.resetApplicationScreenBrightness();
      } catch (_) {}
    }
  }
}

Future<void> _showWebQrDialogRaw(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.8),
    builder: (dialogContext) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const WebQrPoster(),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () => Navigator.pop(dialogContext),
                icon: const Icon(Icons.close, color: Colors.white),
                label: const Text('Cerrar',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Póster oscuro del pop-up (primera versión del diseño).
// ---------------------------------------------------------------------------

/// "ESCANEA EL QR" con la imagen corporativa: negro y rojo, logo MIKIDO,
/// título entre corchetes rojos, franjas laterales y marco HUD con esquinas
/// en L alrededor del QR. Siempre oscuro, sin importar el tema.
class WebQrPoster extends StatelessWidget {
  const WebQrPoster({super.key});

  static const _red = AppColors.primary;
  static const _black = Color(0xFF0E0E0E);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _red.withValues(alpha: 0.7), width: 1.5),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_black, Color(0xFF1C0A0D), _black],
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          const Positioned.fill(
              child: CustomPaint(painter: _PosterSideBarsPainter())),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/images/logo_positivo.png', height: 90),
                const SizedBox(height: 12),
                CustomPaint(
                  painter: const _PosterTitleBracketsPainter(),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                    child: Column(
                      children: [
                        Text(
                          'ESCANEA EL QR',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 28,
                            height: 1.1,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Y CONSULTA LOS RESULTADOS',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'EN TIEMPO REAL',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                            color: AppColors.primaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                CustomPaint(
                  foregroundPainter: const _PosterHudCornersPainter(),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Container(
                      width: 240,
                      height: 240,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Image.asset('assets/images/qr.png',
                          fit: BoxFit.contain),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  kWebResultsUrl,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PosterTitleBracketsPainter extends CustomPainter {
  const _PosterTitleBracketsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    const arm = 12.0;
    canvas.drawPath(
        Path()
          ..moveTo(arm, 0)
          ..lineTo(0, 0)
          ..lineTo(0, size.height)
          ..lineTo(arm, size.height),
        p);
    canvas.drawPath(
        Path()
          ..moveTo(size.width - arm, 0)
          ..lineTo(size.width, 0)
          ..lineTo(size.width, size.height)
          ..lineTo(size.width - arm, size.height),
        p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PosterHudCornersPainter extends CustomPainter {
  const _PosterHudCornersPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    const arm = 26.0;
    final w = size.width, h = size.height;

    void corner(Offset o, double dx, double dy) {
      canvas.drawPath(
          Path()
            ..moveTo(o.dx + dx * arm, o.dy)
            ..lineTo(o.dx, o.dy)
            ..lineTo(o.dx, o.dy + dy * arm),
          p);
    }

    corner(const Offset(1.5, 1.5), 1, 1);
    corner(Offset(w - 1.5, 1.5), -1, 1);
    corner(Offset(1.5, h - 1.5), 1, -1);
    corner(Offset(w - 1.5, h - 1.5), -1, -1);

    final dot = Paint()..color = AppColors.primary;
    for (final x in [1.5, w - 1.5]) {
      canvas.drawLine(Offset(x, h / 2 - 12), Offset(x, h / 2 + 12), p);
      canvas.drawCircle(Offset(x, h / 2), 3.5, dot);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PosterSideBarsPainter extends CustomPainter {
  const _PosterSideBarsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = AppColors.primary.withValues(alpha: 0.55);
    final h = size.height, w = size.width;
    canvas.drawPath(
        Path()
          ..moveTo(0, h * 0.30)
          ..lineTo(6, h * 0.34)
          ..lineTo(6, h * 0.66)
          ..lineTo(0, h * 0.70)
          ..close(),
        p);
    canvas.drawPath(
        Path()
          ..moveTo(w, h * 0.30)
          ..lineTo(w - 6, h * 0.34)
          ..lineTo(w - 6, h * 0.66)
          ..lineTo(w, h * 0.70)
          ..close(),
        p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
