import 'package:flutter/material.dart';
import 'package:le7e_phart_app/services/content_service.dart';
import 'package:le7e_phart_app/models/emission_model.dart';
import 'package:le7e_phart_app/widgets/modern_card.dart';
import 'package:le7e_phart_app/widgets/animated_widgets.dart';
import 'package:le7e_phart_app/utils/youtube_utils.dart';

class EmissionsManagementPage extends StatefulWidget {
  const EmissionsManagementPage({super.key});

  @override
  State<EmissionsManagementPage> createState() => _EmissionsManagementPageState();
}

class _EmissionsManagementPageState extends State<EmissionsManagementPage> {
  final ContentService _contentService = ContentService();
  List<EmissionModel> _emissions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEmissions();
  }

  Future<void> _loadEmissions() async {
    print('EmissionsManagementPage._loadEmissions appelé');
    setState(() => _isLoading = true);
    try {
      final emissions = await _contentService.getEmissions();
      print('${emissions.length} émissions reçues');
      setState(() {
        _emissions = emissions;
        _isLoading = false;
      });
    } catch (e) {
      print('Erreur dans _loadEmissions: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Future<void> _deleteEmission(EmissionModel emission) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Voulez-vous vraiment supprimer l\'émission "${emission.title}" ?'),
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
        await _contentService.deleteEmission(emission.id);
        await _loadEmissions();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Émission supprimée avec succès')),
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
        title: const Text('Gestion des Émissions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEmissions,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadEmissions,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: StaggeredAnimationList(
                  children: [
                    _buildInfoCard(context),
                    const SizedBox(height: 24),
                    ..._emissions.map((emission) => _buildEmissionCard(context, emission)),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEmissionDialog(),
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
                  Icons.tv,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'ÉMISSIONS',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.red,
                      letterSpacing: 2,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${_emissions.length} émission(s) enregistrée(s)',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildEmissionCard(BuildContext context, EmissionModel emission) {
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
                  Icons.tv,
                  color: Colors.red,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  emission.title.toUpperCase(),
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
            emission.description,
            style: Theme.of(context).textTheme.bodyMedium,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () => _showEmissionDialog(emission: emission),
                tooltip: 'Modifier',
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteEmission(emission),
                tooltip: 'Supprimer',
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEmissionDialog({EmissionModel? emission}) {
    final titleController = TextEditingController(text: emission?.title ?? '');
    final descriptionController = TextEditingController(text: emission?.description ?? '');
    final imageUrlController = TextEditingController(text: emission?.imageUrl ?? '');
    final youtubeUrlController = TextEditingController(text: emission?.youtubeUrl ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(emission == null ? 'Nouvelle émission' : 'Modifier l\'émission'),
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
                  hintText: 'https://www.youtube.com/...',
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
              print('Bouton Ajouter/Modifier émission cliqué');
              if (titleController.text.isEmpty) {
                print('Erreur: Titre vide');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Veuillez entrer un titre')),
                );
                return;
              }

              print('Création de l\'EmissionModel avec: ${titleController.text}');
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
              
              final newEmission = EmissionModel(
                id: emission?.id ?? '',
                title: titleController.text,
                description: descriptionController.text,
                imageUrl: finalImageUrl,
                youtubeUrl: youtubeUrlController.text.isNotEmpty ? youtubeUrlController.text : null,
                createdAt: emission?.createdAt ?? DateTime.now(),
              );
              
              print('EmissionModel créé avec imageUrl: ${newEmission.imageUrl}');

              print('Tentative d\'ajout à Firestore...');
              try {
                if (emission == null) {
                  print('Appel de addEmission...');
                  await _contentService.addEmission(newEmission);
                  print('addEmission terminé');
                } else {
                  print('Appel de updateEmission...');
                  await _contentService.updateEmission(emission.id, newEmission);
                  print('updateEmission terminé');
                }
                print('Rechargement des émissions...');
                await _loadEmissions();
                print('Émissions rechargées');
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(emission == null ? 'Émission ajoutée' : 'Émission modifiée'),
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
            child: Text(emission == null ? 'Ajouter' : 'Modifier'),
          ),
        ],
      ),
    );
  }
}
