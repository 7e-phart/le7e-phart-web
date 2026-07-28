import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:le7e_phart_app/services/auth_service.dart';
import 'package:le7e_phart_app/features/auth/auth_bloc.dart';
import 'package:le7e_phart_app/widgets/modern_card.dart';
import 'package:le7e_phart_app/widgets/modern_button.dart';
import 'package:le7e_phart_app/widgets/animated_widgets.dart';

class ContentManagementPage extends StatefulWidget {
  const ContentManagementPage({super.key});

  @override
  State<ContentManagementPage> createState() => _ContentManagementPageState();
}

class _ContentManagementPageState extends State<ContentManagementPage> {
  final AuthService _authService = AuthService();
  Map<String, String> _content = {};
  bool _isLoading = true;
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  @override
  void dispose() {
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _loadContent() async {
    setState(() => _isLoading = true);
    try {
      final content = await _authService.getAllContent();
      setState(() {
        _content = content;
        _isLoading = false;
        _controllers.clear();
        
        // Initialiser les champs par défaut s'ils n'existent pas
        final defaultContent = {
          'about_text': 'Le 7e Phart est une association de cinéma basée à Dunkerque. '
              'Nous produisons des courts-métrages, des documentaires et '
              'organisons des événements cinématographiques pour partager '
              'notre passion du 7e art avec le public.',
          'about_title': 'QUI SOMMES-NOUS ?',
          'about_subtitle': 'DÉCOUVRIR NOTRE ASSOCIATION',
          'history_title': 'NOTRE HISTOIRE',
          'history_content': 'Fondée en 2018 par un groupe de passionnés de cinéma dunkerquois, '
              'Le 7e Phart a pour vocation de promouvoir le 7e art dans notre région. '
              'Notre association a grandi au fil des années, passant de quelques '
              'membres fondateurs à une communauté active de plus de 50 adhérents.\n\n'
              'Depuis nos débuts, nous avons produit plus de 15 courts-métrages '
              'et documentaires, organisé de nombreuses projections et événements '
              'cinématographiques, et formé de nombreux jeunes à la réalisation audiovisuelle.',
          'objectives_title': 'NOS OBJECTIFS',
          'objectives': 'Promouvoir la création cinématographique locale\n'
              'Former aux techniques audiovisuelles\n'
              'Organiser des événements culturels\n'
              'Créer une communauté de passionnés\n'
              'Faire connaître le patrimoine cinématographique dunkerquois',
          'team_title': 'LE BUREAU',
          'team': 'Jean Dupont|Président|Cinéaste passionné, fondateur de l\'association\n'
              'Marie Martin|Vice-Présidente|Productrice et monteuse expérimentée\n'
              'Pierre Durand|Secrétaire|Historien du cinéma et enseignant\n'
              'Sophie Bernard|Trésorière|Comptable et gestionnaire de projets culturels',
          'membership_simple_title': 'Adhésion simple',
          'membership_simple_price': '20€ / an',
          'membership_simple_benefits': 'Accès aux projections, newsletter',
          'membership_supported_title': 'Adhésion soutenue',
          'membership_supported_price': '50€ / an',
          'membership_supported_benefits': 'Tout + soutien financier à l\'association',
          'membership_family_title': 'Adhésion famille',
          'membership_family_price': '35€ / an',
          'membership_family_benefits': 'Pour 2 personnes du même foyer',
          'contact_email': 'contact@le7ephart.fr',
          'contact_address': 'Dunkerque, France',
          'contact_phone': 'Sur demande',
          'contact_facebook': 'https://facebook.com/le7ephart',
          'contact_instagram': 'https://www.instagram.com/le7emephart/?hl=fr',
          'contact_youtube': 'https://www.youtube.com/@Le7emephart',
          'contact_tiktok': 'https://www.tiktok.com/@le7emephart',
        };
        
        // Fusionner avec le contenu existant
        defaultContent.forEach((key, value) {
          if (!content.containsKey(key)) {
            _content[key] = value;
          }
        });
        
        _content.forEach((key, value) {
          _controllers[key] = TextEditingController(text: value);
        });
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Future<void> _saveContent(String key) async {
    try {
      await _authService.setContent(key, _controllers[key]!.text);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contenu mis à jour avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveAllContent() async {
    for (var key in _content.keys) {
      await _saveContent(key);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion du Contenu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveAllContent,
            tooltip: 'Tout sauvegarder',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadContent,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadContent,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: StaggeredAnimationList(
                  children: [
                    _buildInfoCard(context),
                    const SizedBox(height: 24),
                    ..._content.entries.map((entry) => _buildContentCard(context, entry.key, entry.value)),
                  ],
                ),
              ),
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
                  Icons.edit_note,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'CONTENU DE L\'APPLICATION',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.red,
                      letterSpacing: 2,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Modifiez les textes affichés dans l\'application. Les changements sont appliqués immédiatement pour tous les utilisateurs.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildContentCard(BuildContext context, String key, String value) {
    final controller = _controllers[key] ?? TextEditingController(text: value);
    
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
                  Icons.label,
                  color: Colors.red,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  key.toUpperCase(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Entrez le texte pour $key',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ModernButton(
                text: 'Sauvegarder',
                onPressed: () => _saveContent(key),
                icon: Icons.save,
                isGradient: true,
                gradientColors: const [Colors.red, Colors.orange],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
