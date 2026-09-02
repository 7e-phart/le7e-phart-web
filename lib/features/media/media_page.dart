import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:le7e_phart_app/services/content_service.dart';
import 'package:le7e_phart_app/services/auth_service.dart';
import 'package:le7e_phart_app/features/auth/auth_bloc.dart';
import 'package:le7e_phart_app/models/article_model.dart';
import 'package:le7e_phart_app/models/user_model.dart';
import 'package:le7e_phart_app/widgets/modern_card.dart';
import 'package:le7e_phart_app/widgets/animated_widgets.dart';
import 'package:intl/intl.dart';
import 'dart:html' as html;

class MediaPage extends StatefulWidget {
  const MediaPage({super.key});

  @override
  State<MediaPage> createState() => _MediaPageState();
}

class _MediaPageState extends State<MediaPage> {
  final ContentService _contentService = ContentService();
  List<ArticleModel> _articles = [];
  bool _isLoading = true;
  UserRole? _userRole;
  String? _userName;
  String? _userId;
  Uint8List? _selectedImageBytes;

  @override
  void initState() {
    super.initState();
    _loadArticles();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      if (mounted) {
        setState(() {
          _userRole = authState.user.role;
          _userName = authState.user.name;
          _userId = authState.user.id;
        });
      }
    }
  }

  Future<void> _loadArticles() async {
    setState(() => _isLoading = true);
    try {
      final articles = await _contentService.getArticles();
      setState(() {
        _articles = articles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadArticles,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              if (_articles.isEmpty)
                _buildEmptyState(context)
              else
                StaggeredAnimationList(
                  children: [
                    if (_articles.isNotEmpty) _buildFeaturedArticle(context, _articles[0]),
                    const SizedBox(height: 24),
                    ..._articles.skip(1).map((article) => _buildArticleCard(context, article)),
                  ],
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: _canAddArticle()
          ? FloatingActionButton(
              onPressed: () => _showAddArticleDialog(),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  bool _canAddArticle() {
    return _userRole == UserRole.admin || _userRole == UserRole.journalist;
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.newspaper,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'LE MÉDIA',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            Icon(
              Icons.article_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun article pour le moment',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey[400],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Revenez bientôt pour découvrir nos actualités',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedArticle(BuildContext context, ArticleModel article) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 250,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
              image: article.imageUrl.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(article.imageUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: article.imageUrl.isEmpty
                ? const Center(
                    child: Icon(Icons.image, size: 60, color: Colors.grey),
                  )
                : null,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'À LA UNE',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            article.title.toUpperCase(),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
          ),
          const SizedBox(height: 12),
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
                      fontWeight: FontWeight.w500,
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
                DateFormat('dd MMM yyyy', 'fr_FR').format(article.createdAt),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            article.content,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.6,
                ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildArticleCard(BuildContext context, ArticleModel article) {
    return ModernCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          article.authorName,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('dd MMM yyyy', 'fr_FR').format(article.createdAt),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                  image: article.imageUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(article.imageUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: article.imageUrl.isEmpty
                    ? const Center(
                        child: Icon(Icons.image, size: 30, color: Colors.grey),
                      )
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            article.content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                  color: Colors.grey[700],
                ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _showAddArticleDialog() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    final imageUrlController = TextEditingController();
    setState(() {
      _selectedImageBytes = null;
    });

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Nouvel article'),
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
                  maxLines: 8,
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
                ElevatedButton.icon(
                  onPressed: () => _pickImage(setDialogState),
                  icon: const Icon(Icons.image),
                  label: const Text('Choisir une image'),
                ),
                if (_selectedImageBytes != null) ...[
                  const SizedBox(height: 12),
                  const Text('Image sélectionnée'),
                ],
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

                String finalImageUrl = imageUrlController.text;

                if (_selectedImageBytes != null) {
                  try {
                    final uploadedUrl = await _uploadImage(_selectedImageBytes!);
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
                  id: '',
                  title: titleController.text,
                  imageUrl: finalImageUrl,
                  content: contentController.text,
                  authorId: _userId ?? '',
                  authorName: _userName ?? 'Anonyme',
                  createdAt: DateTime.now(),
                  updatedAt: null,
                );

                try {
                  await _contentService.addArticle(newArticle);
                  await _loadArticles();
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Article ajouté avec succès')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur: $e')),
                    );
                  }
                }
              },
              child: const Text('Publier'),
            ),
          ],
        ),
      ),
    );
  }

  void _pickImage(StateSetter setDialogState) {
    final input = html.FileUploadInputElement()..accept = 'image/*';
    input.click();
    input.onChange.listen((e) {
      final files = input.files;
      if (files != null && files.isNotEmpty) {
        final reader = html.FileReader();
        reader.readAsArrayBuffer(files[0]);
        reader.onLoadEnd.listen((e) {
          setDialogState(() {
            _selectedImageBytes = reader.result as Uint8List;
          });
        });
      }
    });
  }

  Future<String?> _uploadImage(Uint8List bytes) async {
    // Placeholder pour l'upload Firebase Storage
    // TODO: Implémenter l'upload réel sur Firebase Storage
    return null;
  }
}
