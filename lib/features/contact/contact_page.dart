import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:le7e_phart_app/widgets/modern_card.dart';
import 'package:le7e_phart_app/widgets/modern_button.dart';
import 'package:le7e_phart_app/widgets/animated_widgets.dart';
import 'package:le7e_phart_app/services/auth_service.dart';
import 'package:le7e_phart_app/services/content_service.dart';
import 'package:le7e_phart_app/models/contact_message_model.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  final AuthService _authService = AuthService();
  final ContentService _contentService = ContentService();
  
  Map<String, String> _contactInfo = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContactInfo();
  }

  Future<void> _loadContactInfo() async {
    try {
      final content = await _authService.getAllContent();
      setState(() {
        _contactInfo = {
          'email': content['contact_email'] ?? 'contact@le7ephart.fr',
          'address': content['contact_address'] ?? 'Dunkerque, France',
          'phone': content['contact_phone'] ?? 'Sur demande',
          'facebook': content['contact_facebook'] ?? 'https://facebook.com/le7ephart',
          'instagram': content['contact_instagram'] ?? 'https://www.instagram.com/le7emephart/?hl=fr',
          'youtube': content['contact_youtube'] ?? 'https://www.youtube.com/@Le7emephart',
          'tiktok': content['contact_tiktok'] ?? 'https://www.tiktok.com/@le7emephart',
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    if (_formKey.currentState!.validate()) {
      try {
        final message = ContactMessageModel(
          id: '',
          name: _nameController.text,
          email: _emailController.text,
          subject: _subjectController.text,
          message: _messageController.text,
          createdAt: DateTime.now(),
        );
        
        await _contentService.addContactMessage(message);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Message envoyé avec succès !'),
            backgroundColor: Colors.green,
          ),
        );

        _formKey.currentState!.reset();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: _contactInfo['email'] ?? 'contact@le7ephart.fr',
    );
    try {
      final launched = await launchUrl(emailUri, mode: LaunchMode.externalApplication);
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
  }

  Future<void> _launchFacebook() async {
    final Uri url = Uri.parse(_contactInfo['facebook'] ?? 'https://facebook.com/le7ephart');
    try {
      final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
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
  }

  Future<void> _launchInstagram() async {
    final Uri url = Uri.parse(_contactInfo['instagram'] ?? 'https://www.instagram.com/le7emephart/?hl=fr');
    try {
      final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
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
  }

  Future<void> _launchYouTube() async {
    final Uri url = Uri.parse(_contactInfo['youtube'] ?? 'https://www.youtube.com/@Le7emephart');
    try {
      final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
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
  }

  Future<void> _launchTikTok() async {
    final Uri url = Uri.parse(_contactInfo['tiktok'] ?? 'https://www.tiktok.com/@le7emephart');
    try {
      final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
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
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: StaggeredAnimationList(
        children: [
          _buildContactInfo(context),
          const SizedBox(height: 24),
          _buildContactForm(context),
          const SizedBox(height: 24),
          _buildSocialMedia(context),
        ],
      ),
    );
  }

  Widget _buildContactInfo(BuildContext context) {
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
                  Icons.contact_mail,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'NOUS CONTACTER',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      letterSpacing: 2,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildContactItem(
            context,
            Icons.email,
            'Email',
            _contactInfo['email'] ?? 'contact@le7ephart.fr',
            _launchEmail,
          ),
          const SizedBox(height: 12),
          _buildContactItem(
            context,
            Icons.location_on,
            'Adresse',
            _contactInfo['address'] ?? 'Dunkerque, France',
            null,
          ),
          const SizedBox(height: 12),
          _buildContactItem(
            context,
            Icons.phone,
            'Téléphone',
            _contactInfo['phone'] ?? 'Sur demande',
            null,
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    VoidCallback? onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
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
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactForm(BuildContext context) {
    return ModernCard(
      child: Form(
        key: _formKey,
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
                    Icons.message,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'FORMULAIRE DE CONTACT',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        letterSpacing: 2,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildModernTextField(
              context,
              _nameController,
              'Nom',
              Icons.person,
              (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer votre nom';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildModernTextField(
              context,
              _emailController,
              'Email',
              Icons.email,
              (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer votre email';
                }
                return null;
              },
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            _buildModernTextField(
              context,
              _subjectController,
              'Sujet',
              Icons.subject,
              (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer un sujet';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildModernTextField(
              context,
              _messageController,
              'Message',
              Icons.message,
              (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer votre message';
                }
                return null;
              },
              maxLines: 5,
            ),
            const SizedBox(height: 24),
            ModernButton(
              text: 'Envoyer le message',
              onPressed: _sendMessage,
              icon: Icons.send,
              isGradient: true,
              gradientColors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernTextField(
    BuildContext context,
    TextEditingController controller,
    String label,
    IconData icon,
    String? Function(String?) validator, {
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label.toUpperCase(),
          prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
      ),
    );
  }

  Widget _buildSocialMedia(BuildContext context) {
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
                  Icons.share,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'SUIS NOUS SUR LES RÉSEAUX!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      letterSpacing: 2,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildModernSocialButton(
                context,
                'YouTube',
                _contactInfo['youtube'] ?? 'https://www.youtube.com/@Le7emephart',
                Icons.play_circle_filled,
                Colors.red,
                _launchYouTube,
              ),
              _buildModernSocialButton(
                context,
                'Instagram',
                _contactInfo['instagram'] ?? 'https://www.instagram.com/le7emephart/?hl=fr',
                Icons.camera_alt,
                Colors.purple,
                _launchInstagram,
              ),
              _buildModernSocialButton(
                context,
                'TikTok',
                _contactInfo['tiktok'] ?? 'https://www.tiktok.com/@le7emephart',
                Icons.music_note,
                Colors.black,
                _launchTikTok,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernSocialButton(
    BuildContext context,
    String label,
    String url,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 40,
              color: color,
            ),
            const SizedBox(height: 12),
            Text(
              label.toUpperCase(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
