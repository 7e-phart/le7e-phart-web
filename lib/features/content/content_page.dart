import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:le7e_phart_app/services/content_service.dart';
import 'package:le7e_phart_app/models/emission_model.dart';
import 'package:le7e_phart_app/models/film_model.dart';
import 'package:le7e_phart_app/widgets/modern_card.dart';
import 'package:le7e_phart_app/widgets/animated_widgets.dart';

class ContentPage extends StatefulWidget {
  const ContentPage({super.key});

  @override
  State<ContentPage> createState() => _ContentPageState();
}

class _ContentPageState extends State<ContentPage> {
  final ContentService _contentService = ContentService();
  List<EmissionModel> _emissions = [];
  List<FilmModel> _films = [];
  bool _isLoading = true;
  String _selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    setState(() => _isLoading = true);
    try {
      final emissions = await _contentService.getEmissions();
      final films = await _contentService.getFilms();
      setState(() {
        _emissions = emissions;
        _films = films;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<dynamic> _getFilteredContent() {
    switch (_selectedCategory) {
      case 'emissions':
        return _emissions.where((e) => e.category == 'emission').toList();
      case 'films':
        return _films.where((f) => f.category == 'film').toList();
      case 'reportage':
        return _films.where((f) => f.category == 'reportage').toList();
      default:
        return [..._emissions, ..._films];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredContent = _getFilteredContent();

    return RefreshIndicator(
      onRefresh: _loadContent,
      child: Column(
        children: [
          _buildCategoryFilter(context),
          Expanded(
            child: filteredContent.isEmpty
                ? _buildEmptyState(context)
                : _buildContentList(context, filteredContent),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildCategoryChip('Tous', 'all'),
            const SizedBox(width: 8),
            _buildCategoryChip('Émissions', 'emissions'),
            const SizedBox(width: 8),
            _buildCategoryChip('Courts-métrages', 'films'),
            const SizedBox(width: 8),
            _buildCategoryChip('Reportages', 'reportage'),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, String value) {
    final isSelected = _selectedCategory == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedCategory = value;
        });
      },
      selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      checkmarkColor: Theme.of(context).colorScheme.primary,
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            Icon(
              Icons.video_library,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun contenu disponible',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey[400],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Revenez bientôt pour découvrir nos contenus',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentList(BuildContext context, List<dynamic> content) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: content.length,
      itemBuilder: (context, index) {
        if (content[index] is EmissionModel) {
          return _buildEmissionCard(context, content[index] as EmissionModel);
        } else {
          return _buildFilmCard(context, content[index] as FilmModel);
        }
      },
    );
  }

  Widget _buildEmissionCard(BuildContext context, EmissionModel emission) {
    return ModernCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (emission.imageUrl != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                emission.imageUrl!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(child: Icon(Icons.broken_image, size: 48)),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'ÉMISSION',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Ajouté le ${_formatDate(emission.createdAt)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            emission.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            emission.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[700],
                ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          if (emission.youtubeUrl != null) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                final url = Uri.parse(emission.youtubeUrl!);
                try {
                  final launched = await launchUrl(
                    url,
                    mode: LaunchMode.platformDefault,
                  );
                  if (!launched && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Impossible d\'ouvrir le lien')),
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
              icon: const Icon(Icons.play_circle),
              label: const Text('Voir sur YouTube'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
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
          if (film.imageUrl != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                film.imageUrl!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(child: Icon(Icons.broken_image, size: 48)),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: film.category == 'reportage'
                      ? Colors.orange.withOpacity(0.1)
                      : Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  film.category == 'reportage' ? 'REPORTAGE' : 'COURT-MÉTRAGE',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: film.category == 'reportage'
                            ? Colors.orange
                            : Colors.purple,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Ajouté le ${_formatDate(film.createdAt)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            film.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            film.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[700],
                ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          if (film.youtubeUrl != null) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                final url = Uri.parse(film.youtubeUrl!);
                try {
                  final launched = await launchUrl(
                    url,
                    mode: LaunchMode.platformDefault,
                  );
                  if (!launched && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Impossible d\'ouvrir le lien')),
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
              icon: const Icon(Icons.play_circle),
              label: const Text('Voir sur YouTube'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
