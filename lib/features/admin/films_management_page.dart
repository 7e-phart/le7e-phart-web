import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:le7e_phart_app/services/content_service.dart';
import 'package:le7e_phart_app/models/film_model.dart';
import 'package:le7e_phart_app/widgets/modern_card.dart';
import 'package:le7e_phart_app/widgets/animated_widgets.dart';
import 'package:le7e_phart_app/utils/youtube_utils.dart';
import 'dart:typed_data';
import 'dart:html' as html;

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

  Future<String?> _uploadImage(Uint8List bytes) async {
    try {
      final fileName = 'films_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = FirebaseStorage.instance.ref().child('films_images/$fileName');
      
      final uploadTask = ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Erreur lors de l\'upload de l\'image: $e');
      return null;
    }
  }

  Future<Uint8List?> _pickImage() async {
    try {
      final input = html.FileUploadInputElement();
      input.accept = 'image/*';
      input.click();

      await input.onChange.first;
      
      if (input.files != null && input.files!.isNotEmpty) {
        final file = input.files!.first;
        final reader = html.FileReader();
        reader.readAsArrayBuffer(file);
        await reader.onLoad.first;
        
        final bytes = reader.result as List<int>;
        return Uint8List.fromList(bytes);
      }
      return null;
    } catch (e) {
      print('Erreur lors de la sélection de l\'image: $e');
      return null;
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
    final youtubeUrlController = TextEditingController(text: film?.youtubeUrl ?? '');
    String category = film?.category ?? 'film';
    Uint8List? selectedImageBytes;
    String? currentImageUrl = film?.imageUrl;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(film == null ? 'Nouveau contenu' : 'Modifier le contenu'),
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
                DropdownButtonFormField<String>(
                  value: category,
                  decoration: const InputDecoration(
                    labelText: 'Catégorie',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'film', child: Text('Court-métrage')),
                    DropdownMenuItem(value: 'reportage', child: Text('Reportage')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() {
                        category = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: youtubeUrlController,
                  decoration: const InputDecoration(
                    labelText: 'URL YouTube/Spotify (optionnel)',
                    hintText: 'https://www.youtube.com/... ou https://open.spotify.com/...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                if (selectedImageBytes != null)
                  Column(
                    children: [
                      Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle, color: Colors.green, size: 40),
                              SizedBox(height: 8),
                              Text('Image sélectionnée'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () {
                          setDialogState(() {
                            selectedImageBytes = null;
                          });
                        },
                        icon: const Icon(Icons.delete),
                        label: const Text('Supprimer l\'image'),
                      ),
                    ],
                  )
                else if (currentImageUrl != null)
                  Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          currentImageUrl!,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () {
                          setDialogState(() {
                            currentImageUrl = null;
                          });
                        },
                        icon: const Icon(Icons.delete),
                        label: const Text('Supprimer l\'image'),
                      ),
                    ],
                  )
                else
                  OutlinedButton.icon(
                    onPressed: () async {
                      final imageBytes = await _pickImage();
                      if (imageBytes != null) {
                        setDialogState(() {
                          selectedImageBytes = imageBytes;
                        });
                      }
                    },
                    icon: const Icon(Icons.image),
                    label: const Text('Ajouter une image'),
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

                String? imageUrl = currentImageUrl;
                if (selectedImageBytes != null) {
                  print('Upload d\'image en cours...');
                  try {
                    final uploadedUrl = await _uploadImage(selectedImageBytes!);
                    print('Upload terminé, URL: $uploadedUrl');
                    if (uploadedUrl != null) {
                      imageUrl = uploadedUrl;
                    } else {
                      print('Erreur: Upload d\'image échoué (URL null)');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Erreur lors de l\'upload de l\'image. Contenu ajouté sans image.'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }
                  } catch (e) {
                    print('Erreur lors de l\'upload: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erreur lors de l\'upload de l\'image: $e. Contenu ajouté sans image.'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                } else if (imageUrl == null && youtubeUrlController.text.isNotEmpty) {
                  // Utiliser la miniature YouTube/Spotify si pas d'image uploadée
                  if (!youtubeUrlController.text.contains('spotify.com')) {
                    imageUrl = YoutubeUtils.getThumbnailUrl(youtubeUrlController.text);
                    print('Miniature générée: $imageUrl');
                  }
                }
                
                print('Création du FilmModel avec: ${titleController.text}, imageUrl: $imageUrl');
                final newFilm = FilmModel(
                  id: film?.id ?? '',
                  title: titleController.text,
                  description: descriptionController.text,
                  imageUrl: imageUrl,
                  youtubeUrl: youtubeUrlController.text.isNotEmpty ? youtubeUrlController.text : null,
                  category: category,
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
                        content: Text(film == null ? 'Contenu ajouté' : 'Contenu modifié'),
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
      ),
    );
  }
}
