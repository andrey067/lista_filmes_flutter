import 'package:flutter/material.dart';

import '../../shared/models/filme.dart';

/// Cartaz de filme estilo streaming.
///
/// Layout: poster 2:3 com gradiente no rodapé para legibilidade do título.
///
/// **Hero (origem da animação):** quando [enableHero] é verdadeiro e há
/// `urlImage`, o poster é filho de [Hero] com
/// `tag: 'filme-poster-${filme.id}'`. Esse **tag** tem de coincidir com o
/// [Hero] no cabeçalho expandido de [FilmeDetailScreen] para o Flutter animar
/// a passagem da miniatura para o poster grande. Sem URL não há `Hero` aqui,
/// logo não há transição partilhada (só animação default da rota).
class FilmeCard extends StatelessWidget {
  const FilmeCard({
    super.key,
    required this.filme,
    required this.onTap,
    this.enableHero = true,
  });

  final Filme filme;
  final VoidCallback onTap;
  final bool enableHero;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final title = filme.name ?? 'Sem título';
    final subtitle =
        '${filme.year}${filme.gender != null ? ' · ${filme.gender}' : ''}';

    Widget poster = ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
      child: AspectRatio(
        aspectRatio: 2 / 3,
        child: Stack(
          fit: StackFit.expand,
          children: [
            filme.urlImage != null && filme.urlImage!.isNotEmpty
                ? Image.network(
                    filme.urlImage!,
                    fit: BoxFit.cover,
                    frameBuilder: (context, child, frame, wasSync) {
                      if (wasSync || frame != null) return child;
                      return ColoredBox(
                        color: scheme.surfaceContainerHigh,
                        child: Center(
                          child: SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: scheme.primary,
                            ),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stack) => ColoredBox(
                      color: scheme.surfaceContainerHigh,
                      child: Icon(
                        Icons.movie_outlined,
                        size: 48,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : ColoredBox(
                    color: scheme.surfaceContainerHigh,
                    child: Icon(
                      Icons.movie_outlined,
                      size: 48,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
            // Gradiente no rodapé para dar contraste ao texto do título.
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.15),
                      Colors.black.withValues(alpha: 0.88),
                    ],
                    stops: const [0.35, 0.65, 1],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 24, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                              letterSpacing: -0.2,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.82),
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    // Hero tag para transição animada do poster para o detail.
    if (enableHero &&
        filme.urlImage != null &&
        filme.urlImage!.isNotEmpty) {
      poster = Hero(
        tag: 'filme-poster-${filme.id}',
        transitionOnUserGestures: true,
        child: poster,
      );
    }

    return Semantics(
      button: true,
      label: '$title, $subtitle',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: scheme.primary.withValues(alpha: 0.12),
          highlightColor: scheme.primary.withValues(alpha: 0.06),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: scheme.outline.withValues(alpha: 0.35),
              ),
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                poster,
              ],
            ),
          ),
        ),
      ),
    );
  }
}