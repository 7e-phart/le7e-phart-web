import 'package:flutter/material.dart';
import 'package:le7e_phart_app/services/content_service.dart';
import 'package:le7e_phart_app/models/film_model.dart';
import 'package:le7e_phart_app/widgets/modern_card.dart';
import 'package:le7e_phart_app/widgets/animated_widgets.dart';
import 'package:le7e_phart_app/utils/youtube_utils.dart';

class FilmsManagementPage extends StatefulWidget {
  const FilmsManagementPage({super.key});

  @override
  State<FilmsManagementPage> createState() => _FilmsManagementPageState();
}

class _FilmsManagementPageState extends State<FilmsManagementPage> {
  final ContentService _contentService = ContentService();
  List<FilmModel> _films = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFilms();
  }

  Future<void> _loadFilms() async {
    print('FilmsManagementPage._loadFilms appelé');
    setState(() => _isLoading = true);
    try {
      final films = await _contentService.getFilms();
      print('${films.length} films reçus');
      setState(() {
        _films = films;
        _isLoading = false;
      });
    } catch (e) {
      print('Erreur dans _loadFilms: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Future<void> _deleteFilm(FilmModel film) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Voulez-vous vraiment supprimerle film "${film.title}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _contentService.deleteFilm(film.id);
        await _loadFilms();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Film supprimé avec succès')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Films'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFilms,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadFilms,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: StaggeredAnimationList(
                  children: [
                    _buildInfoCard(context),
                    const SizedBox(height: 24),
                    ..._films.map((film) => _buildFilmCard(context, film)),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFilmDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return ModernCard(
      withGradient: true,
      gradientColors: [
        Colors.red.withOpacity(0.1),
        Colors.orange.withOpacity(0.05),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.movie,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'FILMS',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.red,
                      letterSpacing: 2,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${_films.length} film(s) enregistré(s)',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildFilmCard(BuildContext context, FilmModel film) {
    return ModernCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.movie,
                  color: Colors.red,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  film.title.toUpperCase(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            film.description,
            style: Theme.of(context).textTheme.bodyMedium,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          if (film.youtubeUrl != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.link,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    film.youtubeUrl!,
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () => _showFilmDialog(film: film),
                tooltip: 'Modifier',
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteFilm(film),
                tooltip: 'Supprimer',
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showFilmDialog({FilmModel? film}) {
    final titleController = TextEditingController(text: film?.title ?? '');
    final descriptionController = TextEditingController(text: film?.description ?? '');
    final imageUrlController = TextEditingController(text: film?.imageUrl ?? '');
    final youtubeUrlController = TextEditingController(text: film?.youtubeUrl ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(film == null ? 'Nouveau film' : 'Modifier le film'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Titre',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL de l\'image (optionnel)',
                  hintText: 'https://...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: youtubeUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL YouTube (optionnel)',
                  hintText: 'https://www.youtube.com/watch?v=...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              print('Bouton Ajouter/Modifier film cliqué');
              if (titleController.text.isEmpty) {
                print('Erreur: Titre vide');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Veuillez entrer un titre')),
                );
                return;
              }

              print('Création du FilmModel avec: ${titleController.text}');
              print('URL YouTube fournie: ${youtubeUrlController.text}');
              print('URL image fournie: ${imageUrlController.text}');
              
              // Déterminer l'URL de l'image : utiliser l'image personnalisée si fournie, sinon la miniature YouTube
              String? finalImageUrl;
              if (imageUrlController.text.isNotEmpty) {
                finalImageUrl = imageUrlController.text;
                print('Utilisation de l\'image personnalisée: $finalImageUrl');
              } else if (youtubeUrlController.text.isNotEmpty) {
                finalImageUrl = YoutubeUtils.getThumbnailUrl(youtubeUrlController.text);
                print('Miniature YouTube générée: $finalImageUrl');
              } else {
                print('Aucune image ni URL YouTube fournie');
              }
              
              final newFilm = FilmModel(
                id: film?.id ?? '',
                title: titleController.text,
                description: descriptionController.text,
                imageUrl: finalImageUrl,
                youtubeUrl: youtubeUrlController.text.isNotEmpty ? youtubeUrlController.text : null,
                createdAt: film?.createdAt ?? DateTime.now(),
              );
              
              print('FilmModel créé avec imageUrl: ${newFilm.imageUrl}');

              print('Tentative d\'ajout à Firestore...');
              try {
                if (film == null) {
                  print('Appel de addFilm...');
                  await _contentService.addFilm(newFilm);
                  print('addFilm terminé');
                } else {
                  print('Appel de updateFilm...');
                  await _contentService.updateFilm(film.id, newFilm);
                  print('updateFilm terminé');
                }
                print('Rechargement des films...');
                await _loadFilms();
                print('Films rechargés');
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(film == null ? 'Film ajouté' : 'Film modifié'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                print('ERREUR lors de l\'ajout: $e');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur: $e'),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 5),
                    ),
                  );
                }
              }
            },
            child: Text(film == null ? 'Ajouter' : 'Modifier'),
          ),
        ],
      ),
    );
  }
}
