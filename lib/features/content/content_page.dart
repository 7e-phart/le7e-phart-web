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
      child: SingleChildScrollView(
        child: StaggeredAnimationList(
          children: [
            _buildHeader(context),
            _buildCategoryFilter(context),
            if (filteredContent.isEmpty)
              _buildEmptyState(context)
            else
              _buildResponsiveContent(context, filteredContent),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsiveContent(BuildContext context, List<dynamic> content) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Utiliser une mise en page en grille pour les écrans larges (> 800px)
        if (constraints.maxWidth > 800) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.7,
              ),
              itemCount: content.length,
              itemBuilder: (context, index) {
                if (content[index] is EmissionModel) {
                  return _buildEmissionCard(context, content[index] as EmissionModel);
                } else {
                  return _buildFilmCard(context, content[index] as FilmModel);
                }
              },
            ),
          );
        } else {
          // Mise en page en liste pour les écrans mobiles
          return Column(
            children: content.asMap().entries.map((entry) {
              if (entry.value is EmissionModel) {
                return _buildEmissionCard(context, entry.value as EmissionModel);
              } else {
                return _buildFilmCard(context, entry.value as FilmModel);
              }
            }).toList(),
          );
        }
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.video_library,
              size: 80,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'NOS CONTENUS',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              'ÉMISSIONS • FILMS • REPORTAGES',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(BuildContext context) {
    return ModernCard(
      margin: const EdgeInsets.all(16),
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
                  Icons.filter_list,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'FILTRER PAR CATÉGORIE',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      letterSpacing: 1,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
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
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, String value) {
    final isSelected = _selectedCategory == value;
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedCategory = value;
        });
      },
      selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      checkmarkColor: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.primary.withOpacity(0.2),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return ModernCard(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.video_library,
                size: 80,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Aucun contenu disponible',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Revenez bientôt pour découvrir nos contenus',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildEmissionCard(BuildContext context, EmissionModel emission) {
    final isSpotify = emission.youtubeUrl != null && _isSpotifyUrl(emission.youtubeUrl!);
    final displayUrl = isSpotify ? emission.youtubeUrl : emission.youtubeUrl;
    
    return ModernCard(
      margin: const EdgeInsets.all(16),
      withGradient: true,
      gradientColors: [
        Theme.of(context).colorScheme.primary.withOpacity(0.1),
        Theme.of(context).colorScheme.secondary.withOpacity(0.05),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (emission.imageUrl != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                emission.imageUrl!,
                width: double.infinity,
                height: 250,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 250,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                    ),
                  ),
                ),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 250,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.podcasts,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
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
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            emission.title.toUpperCase(),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            emission.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.6,
                  color: Colors.grey[700],
                  fontSize: 16,
                ),
          ),
          if (displayUrl != null) ...[
            const SizedBox(height: 20),
            _buildActionButton(context, displayUrl, isSpotify),
          ],
        ],
      ),
    );
  }

  Widget _buildFilmCard(BuildContext context, FilmModel film) {
    final isSpotify = film.youtubeUrl != null && _isSpotifyUrl(film.youtubeUrl!);
    final displayUrl = isSpotify ? film.youtubeUrl : film.youtubeUrl;
    final isReportage = film.category == 'reportage';
    
    return ModernCard(
      margin: const EdgeInsets.all(16),
      withGradient: true,
      gradientColors: [
        Theme.of(context).colorScheme.primary.withOpacity(0.1),
        Theme.of(context).colorScheme.secondary.withOpacity(0.05),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (film.imageUrl != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                film.imageUrl!,
                width: double.infinity,
                height: 250,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 250,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                    ),
                  ),
                ),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 250,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isReportage ? Colors.orange : Colors.purple,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isReportage ? Icons.article : Icons.movie,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: (isReportage ? Colors.orange : Colors.purple).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isReportage ? 'REPORTAGE' : 'COURT-MÉTRAGE',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isReportage ? Colors.orange : Colors.purple,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Ajouté le ${_formatDate(film.createdAt)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            film.title.toUpperCase(),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            film.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.6,
                  color: Colors.grey[700],
                  fontSize: 16,
                ),
          ),
          if (displayUrl != null) ...[
            const SizedBox(height: 20),
            _buildActionButton(context, displayUrl, isSpotify),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String url, bool isSpotify) {
    if (isSpotify) {
      return ElevatedButton.icon(
        onPressed: () async {
          final uri = Uri.parse(url);
          try {
            final launched = await launchUrl(
              uri,
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
        icon: const Icon(Icons.music_note),
        label: const Text('Écouter sur Spotify'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1DB954),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 48),
        ),
      );
    } else {
      return ElevatedButton.icon(
        onPressed: () async {
          final uri = Uri.parse(url);
          try {
            final launched = await launchUrl(
              uri,
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
          minimumSize: const Size(double.infinity, 48),
        ),
      );
    }
  }

  bool _isSpotifyUrl(String url) {
    return url.contains('spotify.com');
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
