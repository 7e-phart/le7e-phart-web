import 'package:flutter/material.dart';
import 'package:le7e_phart_app/services/content_service.dart';
import 'package:le7e_phart_app/models/partner_model.dart';
import 'package:le7e_phart_app/widgets/modern_card.dart';
import 'package:le7e_phart_app/widgets/modern_button.dart';
import 'package:le7e_phart_app/widgets/animated_widgets.dart';

class PartnersManagementPage extends StatefulWidget {
  const PartnersManagementPage({super.key});

  @override
  State<PartnersManagementPage> createState() => _PartnersManagementPageState();
}

class _PartnersManagementPageState extends State<PartnersManagementPage> {
  final ContentService _contentService = ContentService();
  List<PartnerModel> _partners = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPartners();
  }

  Future<void> _loadPartners() async {
    print('PartnersManagementPage._loadPartners appelé');
    setState(() => _isLoading = true);
    try {
      final partners = await _contentService.getPartners();
      print('${partners.length} partenaires reçus dans PartnersManagementPage');
      setState(() {
        _partners = partners;
        _isLoading = false;
      });
    } catch (e) {
      print('Erreur dans PartnersManagementPage._loadPartners: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Future<void> _deletePartner(PartnerModel partner) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Voulez-vous vraiment supprimer le partenaire ${partner.name} ?'),
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
        await _contentService.deletePartner(partner.id);
        await _loadPartners();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Partenaire supprimé avec succès')),
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
        title: const Text('Gestion des Partenaires'),
 actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPartners,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadPartners,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: StaggeredAnimationList(
                  children: [
                    ..._partners.map((partner) => _buildPartnerCard(context, partner)),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPartnerDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPartnerCard(BuildContext context, PartnerModel partner) {
    return ModernCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      partner.name.toUpperCase(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      partner.websiteUrl,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () => _showPartnerDialog(partner: partner),
                tooltip: 'Modifier',
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deletePartner(partner),
                tooltip: 'Supprimer',
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showPartnerDialog({PartnerModel? partner}) {
    final nameController = TextEditingController(text: partner?.name ?? '');
    final logoUrlController = TextEditingController(text: partner?.logoUrl ?? '');
    final websiteUrlController = TextEditingController(text: partner?.websiteUrl ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(partner == null ? 'Nouveau partenaire' : 'Modifier le partenaire'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom du partenaire',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: logoUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL du logo (placeholder pour l\'instant)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: websiteUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL du site web',
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
              if (nameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Veuillez entrer un nom')),
                );
                return;
              }

              final newPartner = PartnerModel(
                id: partner?.id ?? '',
                name: nameController.text,
                logoUrl: logoUrlController.text,
                websiteUrl: websiteUrlController.text,
                createdAt: partner?.createdAt ?? DateTime.now(),
              );

              try {
                if (partner == null) {
                  await _contentService.addPartner(newPartner);
                } else {
                  await _contentService.updatePartner(partner.id, newPartner);
                }
                await _loadPartners();
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(partner == null ? 'Partenaire ajouté' : 'Partenaire modifié'),
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
            child: Text(partner == null ? 'Ajouter' : 'Modifier'),
          ),
        ],
      ),
    );
  }
}
