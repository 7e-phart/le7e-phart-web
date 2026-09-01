import 'package:flutter/material.dart';
import 'package:le7e_phart_app/widgets/modern_card.dart';
import 'package:le7e_phart_app/widgets/animated_widgets.dart';
import 'package:le7e_phart_app/services/auth_service.dart';
import 'package:le7e_phart_app/services/content_service.dart';
import 'package:le7e_phart_app/models/partner_model.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  final AuthService _authService = AuthService();
  final ContentService _contentService = ContentService();
  Map<String, String> _content = {};
  List<PartnerModel> _partners = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    setState(() => _isLoading = true);
    try {
      final content = await _authService.getAllContent();
      final partners = await _contentService.getPartners();
      setState(() {
        _content = content;
        _partners = partners;
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

    return RefreshIndicator(
      onRefresh: _loadContent,
      child: SingleChildScrollView(
        child: StaggeredAnimationList(
          children: [
            _buildHeader(context),
            _buildHistory(context),
            _buildObjectives(context),
            _buildTeam(context),
            _buildPartners(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
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
              Icons.groups,
              size: 80,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _content['about_title'] ?? 'QUI SOMMES-NOUS ?',
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
              _content['about_subtitle'] ?? 'DÉCOUVRIR NOTRE ASSOCIATION',
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

  Widget _buildHistory(BuildContext context) {
    return ModernCard(
      withGradient: true,
      gradientColors: [
        Theme.of(context).colorScheme.primary.withOpacity(0.1),
        Theme.of(context).colorScheme.secondary.withOpacity(0.05),
      ],
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
                  Icons.history,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                _content['history_title'] ?? 'NOTRE HISTOIRE',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      letterSpacing: 2,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            _content['history_content'] ?? 'Fondée en 2018 par un groupe de passionnés de cinéma dunkerquois, '
            'Le 7e Phart a pour vocation de promouvoir le 7e art dans notre région. '
            'Notre association a grandi au fil des années, passant de quelques '
            'membres fondateurs à une communauté active de plus de 50 adhérents.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.6,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildObjectives(BuildContext context) {
    final objectivesText = _content['objectives'] ?? 
        'Promouvoir la création cinématographique locale\n'
        'Former aux techniques audiovisuelles\n'
        'Organiser des événements culturels\n'
        'Créer une communauté de passionnés\n'
        'Faire connaître le patrimoine cinématographique dunkerquois';
    
    final objectives = objectivesText.split('\n');

    return ModernCard(
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
                  Icons.flag,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                _content['objectives_title'] ?? 'NOS OBJECTIFS',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      letterSpacing: 2,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...objectives.asMap().entries.map((entry) {
            final icons = [Icons.movie_creation, Icons.school, Icons.theater_comedy, Icons.diversity_3, Icons.public];
            final icon = entry.key < icons.length ? icons[entry.key] : Icons.star;
            return _buildObjectiveItem(context, icon, entry.value);
          }),
        ],
      ),
    );
  }

  Widget _buildObjectiveItem(BuildContext context, IconData icon, String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeam(BuildContext context) {
    final teamText = _content['team'] ?? 
        'Jean Dupont|Président|Cinéaste passionné, fondateur de l\'association\n'
        'Marie Martin|Vice-Présidente|Productrice et monteuse expérimentée\n'
        'Pierre Durand|Secrétaire|Historien du cinéma et enseignant\n'
        'Sophie Bernard|Trésorière|Comptable et gestionnaire de projets culturels';
    
    final boardMembers = teamText.split('\n').map((line) {
      final parts = line.split('|');
      return BoardMember(
        name: parts.length > 0 ? parts[0] : 'Nom',
        role: parts.length > 1 ? parts[1] : 'Rôle',
        description: parts.length > 2 ? parts[2] : 'Description',
      );
    }).toList();

    return ModernCard(
      withGradient: true,
      gradientColors: [
        Theme.of(context).colorScheme.primary.withOpacity(0.1),
        Theme.of(context).colorScheme.secondary.withOpacity(0.05),
      ],
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
                  Icons.business_center,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                _content['team_title'] ?? 'LE BUREAU',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      letterSpacing: 2,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...boardMembers.map((member) => _buildMemberCard(context, member)),
        ],
      ),
    );
  }

  Widget _buildMemberCard(BuildContext context, BoardMember member) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                member.name.isNotEmpty ? member.name[0] : '?',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name.toUpperCase(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    member.role.toUpperCase(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  member.description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartners(BuildContext context) {
    return ModernCard(
      withGradient: true,
      gradientColors: [
        Theme.of(context).colorScheme.primary.withOpacity(0.1),
        Theme.of(context).colorScheme.secondary.withOpacity(0.05),
      ],
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
                  Icons.handshake,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'NOS PARTENAIRES',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      letterSpacing: 2,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_partners.isEmpty)
            Text(
              'Aucun partenaire pour le moment',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            )
          else
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: _partners.map((partner) => _buildPartnerCard(context, partner)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildPartnerCard(BuildContext context, PartnerModel partner) {
    return InkWell(
      onTap: () async {
        final Uri url = Uri.parse(partner.websiteUrl);
        try {
          final launched = await launchUrl(url, mode: LaunchMode.platformDefault);
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
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.business,
                size: 30,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              partner.name,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class BoardMember {
  final String name;
  final String role;
  final String description;

  BoardMember({
    required this.name,
    required this.role,
    required this.description,
  });
}
