import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:le7e_phart_app/services/content_service.dart';
import 'package:le7e_phart_app/models/news_model.dart';
import 'package:le7e_phart_app/widgets/modern_card.dart';
import 'package:le7e_phart_app/widgets/animated_widgets.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:typed_data';
import 'dart:html' as html;

class NewsManagementPage extends StatefulWidget {
  const NewsManagementPage({super.key});

  @override
  State<NewsManagementPage> createState() => _NewsManagementPageState();
}

class _NewsManagementPageState extends State<NewsManagementPage> {
  final ContentService _contentService = ContentService();
  List<NewsModel> _news = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr_FR', null);
    _loadNews();
  }

  Future<String?> _uploadImage(Uint8List bytes) async {
    try {
      final fileName = 'news_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = FirebaseStorage.instance.ref().child('news_images/$fileName');
      
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

  Future<void> _loadNews() async {
    print('NewsManagementPage._loadNews appelé');
    setState(() => _isLoading = true);
    try {
      final news = await _contentService.getNews();
      print('${news.length} actualités reçues');
      setState(() {
        _news = news;
        _isLoading = false;
      });
    } catch (e) {
      print('Erreur dans _loadNews: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Future<void> _deleteNews(NewsModel newsItem) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Voulez-vous vraiment supprimer l\'actualité "${newsItem.title}" ?'),
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
        await _contentService.deleteNews(newsItem.id);
        await _loadNews();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Actualité supprimée avec succès')),
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
        title: const Text('Gestion des Actualités'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNews,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadNews,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: StaggeredAnimationList(
                  children: [
                    _buildInfoCard(context),
                    const SizedBox(height: 24),
                    ..._news.map((newsItem) => _buildNewsCard(context, newsItem)),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewsDialog(),
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
                  Icons.newspaper,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'ACTUALITÉS',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.red,
                      letterSpacing: 2,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${_news.length} actualité(s) enregistrée(s)',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildNewsCard(BuildContext context, NewsModel newsItem) {
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
                  Icons.article,
                  color: Colors.red,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  newsItem.title.toUpperCase(),
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
            newsItem.content,
            style: Theme.of(context).textTheme.bodyMedium,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 4),
              Text(
                DateFormat('dd/MM/yyyy').format(newsItem.date),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () => _showNewsDialog(news: newsItem),
                tooltip: 'Modifier',
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteNews(newsItem),
                tooltip: 'Supprimer',
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showNewsDialog({NewsModel? news}) {
    final titleController = TextEditingController(text: news?.title ?? '');
    final contentController = TextEditingController(text: news?.content ?? '');
    DateTime selectedDate = news?.date ?? DateTime.now();
    Uint8List? selectedImageBytes;
    String? currentImageUrl = news?.imageUrl;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(news == null ? 'Nouvelle actualité' : 'Modifier l\'actualité'),
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
                  controller: contentController,
                  decoration: const InputDecoration(
                    labelText: 'Contenu',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                ),
                const SizedBox(height: 12),
                ListTile(
                  title: const Text('Date'),
                  subtitle: Text(DateFormat('dd/MM/yyyy').format(selectedDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      selectedDate = picked;
                      setState(() {});
                    }
                  },
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
                          setState(() {
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
                          setState(() {
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
                        setState(() {
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
                print('Bouton Ajouter/Modifier actualité cliqué');
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
                  final uploadedUrl = await _uploadImage(selectedImageBytes!);
                  print('Upload terminé, URL: $uploadedUrl');
                  if (uploadedUrl != null) {
                    imageUrl = uploadedUrl;
                  } else {
                    print('Erreur: Upload d\'image échoué (URL null)');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Erreur lors de l\'upload de l\'image'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                }

                print('Création du NewsModel avec: ${titleController.text}, imageUrl: $imageUrl');
                final newNews = NewsModel(
                  id: news?.id ?? '',
                  title: titleController.text,
                  content: contentController.text,
                  date: selectedDate,
                  createdAt: news?.createdAt ?? DateTime.now(),
                  imageUrl: imageUrl,
                );

                print('Tentative d\'ajout à Firestore...');
                try {
                  if (news == null) {
                    print('Appel de addNews...');
                    await _contentService.addNews(newNews);
                    print('addNews terminé');
                  } else {
                    print('Appel de updateNews...');
                    await _contentService.updateNews(news.id, newNews);
                    print('updateNews terminé');
                  }
                  print('Rechargement des actualités...');
                  await _loadNews();
                  print('Actualités rechargées');
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(news == null ? 'Actualité ajoutée' : 'Actualité modifiée'),
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
              child: Text(news == null ? 'Ajouter' : 'Modifier'),
            ),
          ],
        ),
      ),
    );
  }
}
