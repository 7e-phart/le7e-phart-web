import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:le7e_phart_app/services/content_service.dart';
import 'package:le7e_phart_app/models/emission_model.dart';

class EmissionsPage extends StatefulWidget {
  const EmissionsPage({super.key});

  @override
  State<EmissionsPage> createState() => _EmissionsPageState();
}

class _EmissionsPageState extends State<EmissionsPage> {
  final ContentService _contentService = ContentService();
  List<EmissionModel> _emissions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEmissions();
  }

  Future<void> _loadEmissions() async {
    setState(() => _isLoading = true);
    try {
      final emissions = await _contentService.getEmissions();
      setState(() {
        _emissions = emissions;
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

    if (_emissions.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadEmissions,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.tv, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Aucune émission disponible'),
                  Text('Revenez plus tard pour découvrir nos contenus'),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadEmissions,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _emissions.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ExpansionTile(
              leading: const CircleAvatar(
                child: Icon(Icons.tv),
              ),
              title: Text(_emissions[index].title),
              subtitle: Text(_emissions[index].description),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_emissions[index].imageUrl != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            _emissions[index].imageUrl!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const SizedBox(
                                height: 200,
                                child: Center(child: Icon(Icons.broken_image)),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (_emissions[index].youtubeUrl != null) ...[
                        ElevatedButton.icon(
                          onPressed: () async {
                            final url = Uri.parse(_emissions[index].youtubeUrl!);
                            try {
                              final launched = await launchUrl(
                                url,
                                mode: LaunchMode.externalApplication,
                              );
                              if (!launched) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Impossible d\'ouvrir le lien')),
                                  );
                                }
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
                        const SizedBox(height: 16),
                      ],
                      Text(
                        'Ajouté le ${_formatDate(_emissions[index].createdAt)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
