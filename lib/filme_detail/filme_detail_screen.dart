import 'package:flutter/material.dart';

import '../shared/di/locator.dart';
import '../shared/widgets/loading_indicator.dart';
import 'models/filme_detail_viewmodel.dart';

/// Detalhe do filme com [SliverAppBar], [Hero] no poster e comentários.
///
/// **Hero (destino da animação):** com imagem, o fundo do [FlexibleSpaceBar]
/// contém [Hero] com `tag: 'filme-poster-${filme.id}'`, igual ao de
/// [FilmeCard] na home. O Flutter faz o *flight* entre os dois durante o
/// [Navigator.push] da lista. Sem `urlImage`, mostra-se só cor de superfície
/// e não há segundo Hero (consistente com a origem).
///
/// Secções da UI:
/// - SliverAppBar com poster + título.
/// - Chips: ano, duração, género.
/// - Sinopse.
/// - Comentários: formulário + lista com eliminação.
class FilmeDetailScreen extends StatefulWidget {
  const FilmeDetailScreen({super.key, required this.filmeId});

  final int filmeId;

  @override
  State<FilmeDetailScreen> createState() => _FilmeDetailScreenState();
}

class _FilmeDetailScreenState extends State<FilmeDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  // Resolvido via GetIt factory param — cada ecrã cria a sua instância.
  late final FilmeDetailViewModel _vm =
      getIt<FilmeDetailViewModel>(param1: widget.filmeId);

  @override
  void initState() {
    super.initState();
    _vm.addListener(_onVmChanged);
  }

  void _onVmChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _vm.removeListener(_onVmChanged);
    // Instância criada pela factory do GetIt — libertar o ChangeNotifier.
    _vm.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final filme = _vm.filme;

    if (_vm.isLoading && filme == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Filme')),
        body: const LoadingIndicator(message: 'Carregando…'),
      );
    }

    if (_vm.errorMessage != null && filme == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Filme')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.wifi_off_rounded, size: 56, color: scheme.error),
                const SizedBox(height: 16),
                Text(
                  'Não foi possível carregar',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _vm.errorMessage!,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _vm.load,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Tentar novamente'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (filme == null) {
      return const Scaffold(body: SizedBox.shrink());
    }

    final heroImage = filme.urlImage != null && filme.urlImage!.isNotEmpty;

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverAppBar(
            pinned: true,
            stretch: true,
            expandedHeight: heroImage ? 280 : 120,
            backgroundColor: scheme.surface.withValues(alpha: 0.92),
            foregroundColor: scheme.onSurface,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              titlePadding: const EdgeInsetsDirectional.only(
                start: 56,
                bottom: 14,
                end: 16,
              ),
              title: Text(
                filme.name ?? 'Filme',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  shadows: heroImage
                      ? [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.65),
                            blurRadius: 12,
                          ),
                        ]
                      : null,
                ),
              ),
              background: heroImage
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        // Destino do Hero — mesma tag que [FilmeCard] na home.
                        Hero(
                          tag: 'filme-poster-${filme.id}',
                          transitionOnUserGestures: true,
                          child: Image.network(
                            filme.urlImage!,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => ColoredBox(
                              color: scheme.surfaceContainerHigh,
                              child: Icon(
                                Icons.movie_outlined,
                                size: 72,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.15),
                                Colors.black.withValues(alpha: 0.65),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : ColoredBox(color: scheme.surfaceContainerHigh),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(
                      avatar: Icon(
                        Icons.calendar_today_rounded,
                        size: 18,
                        color: scheme.primary,
                      ),
                      label: Text('${filme.year}'),
                      side: BorderSide(color: scheme.outline.withValues(alpha: 0.35)),
                      backgroundColor:
                          scheme.surfaceContainerHighest.withValues(alpha: 0.65),
                    ),
                    Chip(
                      avatar: Icon(
                        Icons.schedule_rounded,
                        size: 18,
                        color: scheme.secondary,
                      ),
                      label: Text('${filme.duration} min'),
                      side: BorderSide(color: scheme.outline.withValues(alpha: 0.35)),
                      backgroundColor:
                          scheme.surfaceContainerHighest.withValues(alpha: 0.65),
                    ),
                    if (filme.gender != null)
                      Chip(
                        avatar: Icon(
                          Icons.category_rounded,
                          size: 18,
                          color: scheme.tertiary,
                        ),
                        label: Text(filme.gender!),
                        side:
                            BorderSide(color: scheme.outline.withValues(alpha: 0.35)),
                        backgroundColor:
                            scheme.surfaceContainerHighest.withValues(alpha: 0.65),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Sinopse',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  filme.description ?? '',
                  style: textTheme.bodyLarge?.copyWith(
                    height: 1.55,
                    color: scheme.onSurface.withValues(alpha: 0.96),
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Icon(Icons.chat_bubble_outline_rounded,
                        color: scheme.primary, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'Comentários',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_vm.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      _vm.errorMessage!,
                      style: textTheme.bodySmall?.copyWith(color: scheme.error),
                    ),
                  ),
                TextField(
                  controller: _commentController,
                  maxLines: 3,
                  maxLength: 300,
                  decoration: const InputDecoration(
                    labelText: 'Seu comentário',
                    hintText: 'Entre 3 e 300 caracteres',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: scheme.tertiary,
                    foregroundColor: scheme.onTertiary,
                  ),
                  onPressed: _vm.isSavingComment
                      ? null
                      : () async {
                          await _vm.addComentario(_commentController.text);
                          if (mounted && _vm.errorMessage == null) {
                            _commentController.clear();
                          }
                        },
                  icon: _vm.isSavingComment
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: scheme.onTertiary,
                          ),
                        )
                      : Icon(Icons.send_rounded, color: scheme.onTertiary),
                  label: Text(
                    _vm.isSavingComment ? 'Enviando…' : 'Publicar',
                  ),
                ),
                const SizedBox(height: 28),
                if (filme.comments.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        'Seja o primeiro a comentar.',
                        style: textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  )
                else
                  ...filme.comments.map(
                    (c) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Material(
                        color: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(14),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          title: Text(
                            c.comment,
                            style: textTheme.bodyMedium?.copyWith(height: 1.45),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              _formatDate(c.dateCreated),
                              style: textTheme.labelSmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          trailing: IconButton(
                            tooltip: 'Excluir comentário',
                            icon: Icon(Icons.delete_outline_rounded,
                                color: scheme.error),
                            onPressed: () async {
                              final ok = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Excluir comentário?'),
                                  content: const Text(
                                    'Esta ação não pode ser desfeita.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: const Text('Cancelar'),
                                    ),
                                    FilledButton(
                                      style: FilledButton.styleFrom(
                                        backgroundColor: scheme.error,
                                      ),
                                      onPressed: () =>
                                          Navigator.pop(ctx, true),
                                      child: const Text('Excluir'),
                                    ),
                                  ],
                                ),
                              );
                              if (ok == true && context.mounted) {
                                await _vm.deleteComentario(c.id);
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }
}