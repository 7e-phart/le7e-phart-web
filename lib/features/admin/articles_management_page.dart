import 'package:flutter/material.dart';
import 'package:le7e_phart_app/services/content_service.dart';
import 'package:le7e_phart_app/services/image_upload_service.dart';
import 'package:le7e_phart_app/models/article_model.dart';
import 'package:le7e_phart_app/widgets/modern_card.dart';
import 'package:le7e_phart_app/widgets/modern_button.dart';
import 'package:le7e_phart_app/widgets/animated_widgets.dart';
import 'package:le7e_phart_app/features/auth/auth_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:le7e_phart_app/models/user_model.dart';
import 'dart:html' as html;
import 'dart:typed_data';

class ArticlesManagementPage extends StatefulWidget {
  const ArticlesManagementPage({super.key});

  @override
  State<ArticlesManagementPage> createState() => _ArticlesManagementPageState();
}

class _ArticlesManagementPageState extends State<ArticlesManagementPage> {
  final ContentService _contentService = ContentService();
  List<ArticleModel> _articles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  Future<void> _loadArticles() async {
    print('ArticlesManagementPage._loadArticles appelé');
    setState(() => _isLoading = true);
    try {
      final articles = await _contentService.getArticles();
      print('${articles.length} articles reçus dans ArticlesManagementPage');
      setState(() {
        _articles = articles;
        _isLoading = false;
      });
    } catch (e) {
      print('Erreur dans ArticlesManagementPage._loadArticles: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Future<Uint8List?> _pickImage() async {
    final input = html.FileUploadInputElement();
    input.accept = 'image/*';
    input.click();

    await input.onChange.first;

    if (input.files?.isEmpty ?? true) {
      return null;
    }

    final file = input.files!.first;
    final reader = html.FileReader();
    reader.readAsArrayBuffer(file);
    await reader.onLoad.first;

    return Uint8List.fromList(reader.result as List<int>);
  }

  Future<String?> _uploadImage(Uint8List bytes) async {
    final fileName = 'article-image-${DateTime.now().millisecondsSinceEpoch}.jpg';
    return await ImageUploadService.uploadImage(bytes, fileName);
  }

  Future<void> _deleteArticle(ArticleModel article) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Voulez-vous vraiment supprimer l\'article "${article.title}" ?'),
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
        await _contentService.deleteArticle(article.id);
        await _loadArticles();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Article supprimé avec succès')),
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
        title: const Text('Gestion des Articles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadArticles,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadArticles,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: StaggeredAnimationList(
                  children: [
                    ..._articles.map((article) => _buildArticleCard(context, article)),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showArticleDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildArticleCard(BuildContext context, ArticleModel article) {
    return ModernCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (article.imageUrl.isNotEmpty)
            Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(article.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          const SizedBox(height: 16),
          Text(
            article.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.person,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                article.authorName,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.calendar_today,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                article.createdAt.toString().split(' ')[0],
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            article.content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[700],
                ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () => _showArticleDialog(article: article),
                tooltip: 'Modifier',
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteArticle(article),
                tooltip: 'Supprimer',
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showArticleDialog({ArticleModel? article}) {
    final titleController = TextEditingController(text: article?.title ?? '');
    final imageUrlController = TextEditingController(text: article?.imageUrl ?? '');
    final contentController = TextEditingController(text: article?.content ?? '');
    Uint8List? selectedImageBytes;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(article == null ? 'Nouvel article' : 'Modifier l\'article'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Titre de l\'article',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: imageUrlController,
                  decoration: const InputDecoration(
                    labelText: 'URL de l\'image (optionnel)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                ModernButton(
                  text: 'Choisir une image',
                  onPressed: () async {
                    final bytes = await _pickImage();
                    if (bytes != null) {
                      setDialogState(() {
                        selectedImageBytes = bytes;
                      });
                    }
                  },
                  icon: Icons.image,
                ),
                if (selectedImageBytes != null)
                  Padding(
                    padding: const EdgeInsets.only(top:.0),
                    child: Text(
                      'Image sélectionnée (${(selectedImageBytes!.length / 1024).toStringAsFixed(1)} KB)',
                      style: const TextStyle(color: Colors.green),
                    ),
                  ),
                const SizedBox(height: 12),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(
                    labelText: 'Contenu de l\'article',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 10,
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
                if (titleController.text.isEmpty || contentController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Veuillez remplir le titre et le contenu')),
                  );
                  return;
                }

                final state = context.read<AuthBloc>().state;
                if (state is! AuthAuthenticated) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vous devez être connecté')),
                  );
                  return;
                }

                final user = state.user;
                String finalImageUrl = imageUrlController.text;

                if (selectedImageBytes != null) {
                  try {
                    final uploadedUrl = await _uploadImage(selectedImageBytes!);
                    if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
                      finalImageUrl = uploadedUrl;
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur upload image: $e')),
                    );
                  }
                }

                final newArticle = ArticleModel(
                  id: article?.id ?? '',
                  title: titleController.text,
                  imageUrl: finalImageUrl,
                  content: contentController.text,
                  authorId: user.id,
                  authorName: user.name,
                  createdAt: article?.createdAt ?? DateTime.now(),
                  updatedAt: DateTime.now(),
                );

                try {
                  if (article == null) {
                    await _contentService.addArticle(newArticle);
                  } else {
                    await _contentService.updateArticle(article.id, newArticle);
                  }
                  await _loadArticles();
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(article == null ? 'Article ajouté' : 'Article modifié'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erreur: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: Text(article == null ? 'Publier' : 'Modifier'),
            ),
          ],
        ),
      ),
    );
  }
}
