import 'package:flutter/material.dart';

import 'widgets/filme_list.dart';
import 'widgets/search_input.dart';
import '../filme_detail/filme_detail_screen.dart';

/// Home: busca com debounce e lista de filmes com paginação.
///
/// ## Animação para o detalhe ([FilmeDetailScreen])
///
/// O "voo" da imagem do cartaz usa o widget [Hero] do Flutter (*shared element
/// transition*):
///
/// 1. Em cada cartão, [FilmeCard] envolve o poster num [Hero] com
///    `tag: 'filme-poster-${filme.id}'`, mas **só se** existir `urlImage`
///    (sem URL não há Hero na origem).
/// 2. Ao tocar, esta ecrã faz [Navigator.push] com uma nova rota que constrói
///    [FilmeDetailScreen(filmeId: filme.id)]. O detalhe carrega o mesmo filme
///    pela API e coloca outro [Hero] no fundo do [SliverAppBar] com a **mesma
///    tag** e a mesma URL.
/// 3. O motor de rotas do Flutter associa os dois Heroes pela tag e anima a
///    transição entre retângulos de origem e destino (escala/ posição durante o
///    push). `transitionOnUserGestures: true` permite continuar a animação ao
///    arrastar para voltar (no iOS sobretudo).
///
/// Se não houver imagem na lista, não há par Hero na origem: o push é uma
/// transição normal de rota, sem elemento partilhado.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Lista de Filmes',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Descubra e comente',
              style: textTheme.labelMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SearchInput(),
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    scheme.primary.withValues(alpha: 0.06),
                    scheme.surface,
                  ],
                ),
              ),
              child: FilmeList(
                onFilmeTap: (filme) {
                  // Nova rota full-screen; o Hero em FilmeCard + FilmeDetailScreen
                  // (mesma tag) é interpolado pelo Navigator durante o push.
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) =>
                          FilmeDetailScreen(filmeId: filme.id),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}