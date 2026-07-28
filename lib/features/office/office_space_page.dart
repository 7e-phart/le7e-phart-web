import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:le7e_phart_app/features/auth/auth_bloc.dart';
import 'package:le7e_phart_app/features/members/members_bloc.dart';
import 'package:le7e_phart_app/features/finance/finance_bloc.dart';

class OfficeSpacePage extends StatefulWidget {
  const OfficeSpacePage({super.key});

  @override
  State<OfficeSpacePage> createState() => _OfficeSpacePageState();
}

class _OfficeSpacePageState extends State<OfficeSpacePage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<MembersBloc>().add(const LoadMembers());
    context.read<FinanceBloc>().add(const LoadFinances());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Espace Bureau'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(const LogoutRequested());
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          OfficeMembersPage(),
          OfficeFilmsPage(),
          OfficeNewsPage(),
          OfficeEventsPage(),
          OfficeFinancePage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.people),
            label: 'Adhérents',
          ),
          NavigationDestination(
            icon: Icon(Icons.movie),
            label: 'Films',
          ),
          NavigationDestination(
            icon: Icon(Icons.newspaper),
            label: 'Actualités',
          ),
          NavigationDestination(
            icon: Icon(Icons.event),
            label: 'Événements',
          ),
          NavigationDestination(
            icon: Icon(Icons.euro),
            label: 'Finances',
          ),
        ],
      ),
    );
  }
}

class OfficeMembersPage extends StatelessWidget {
  const OfficeMembersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Gestion des adhérents',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddMemberDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Ajouter'),
              ),
            ],
          ),
        ),
        Expanded(
          child: BlocBuilder<MembersBloc, MembersState>(
            builder: (context, state) {
              if (state is MembersLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is MembersLoaded) {
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: state.members.length,
                  itemBuilder: (context, index) {
                    final member = state.members[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(member.firstName[0]),
                        ),
                        title: Text('${member.firstName} ${member.name}'),
                        subtitle: Text('${member.email}\n${member.phone}'),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              member.isActive ? Icons.check_circle : Icons.cancel,
                              color: member.isActive ? Colors.green : Colors.red,
                            ),
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _showEditMemberDialog(context, member);
                                } else if (value == 'delete') {
                                  context.read<MembersBloc>().add(DeleteMember(member.id));
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Modifier'),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Supprimer'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }

              return const Center(child: Text('Erreur de chargement'));
            },
          ),
        ),
      ],
    );
  }

  void _showAddMemberDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddMemberDialog(),
    );
  }

  void _showEditMemberDialog(BuildContext context, member) {
    showDialog(
      context: context,
      builder: (context) => AddMemberDialog(member: member),
    );
  }
}

class AddMemberDialog extends StatefulWidget {
  final Member? member;

  const AddMemberDialog({super.key, this.member});

  @override
  State<AddMemberDialog> createState() => _AddMemberDialogState();
}

class _AddMemberDialogState extends State<AddMemberDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  MembershipType _membershipType = MembershipType.simple;

  @override
  void initState() {
    super.initState();
    if (widget.member != null) {
      _nameController.text = widget.member!.name;
      _firstNameController.text = widget.member!.firstName;
      _emailController.text = widget.member!.email;
      _phoneController.text = widget.member!.phone;
      _membershipType = widget.member!.membershipType;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _firstNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.member == null ? 'Ajouter un adhérent' : 'Modifier l\'adhérent'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'Prénom'),
                validator: (value) => value?.isEmpty ?? true ? 'Requis' : null,
              ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nom'),
                validator: (value) => value?.isEmpty ?? true ? 'Requis' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value?.isEmpty ?? true ? 'Requis' : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Téléphone'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<MembershipType>(
                value: _membershipType,
                decoration: const InputDecoration(labelText: 'Type d\'adhésion'),
                items: const [
                  DropdownMenuItem(
                    value: MembershipType.simple,
                    child: Text('Simple (20€)'),
                  ),
                  DropdownMenuItem(
                    value: MembershipType.supported,
                    child: Text('Soutenu (50€)'),
                  ),
                  DropdownMenuItem(
                    value: MembershipType.family,
                    child: Text('Famille (35€)'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _membershipType = value!;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              if (widget.member == null) {
                context.read<MembersBloc>().add(
                      AddMember(
                        name: _nameController.text,
                        firstName: _firstNameController.text,
                        email: _emailController.text,
                        phone: _phoneController.text,
                        membershipType: _membershipType,
                      ),
                    );
              }
              Navigator.pop(context);
            }
          },
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }
}

class OfficeFilmsPage extends StatelessWidget {
  const OfficeFilmsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.movie,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          const Text('Gestion des films'),
          const SizedBox(height: 8),
          const Text('Ajoutez et gérez vos films ici'),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ajouter un film...')),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Ajouter un film'),
          ),
        ],
      ),
    );
  }
}

class OfficeNewsPage extends StatelessWidget {
  const OfficeNewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.newspaper,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          const Text('Gestion des actualités'),
          const SizedBox(height: 8),
          const Text('Publiez des nouvelles ici'),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Publier une actualité...')),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Publier une actualité'),
          ),
        ],
      ),
    );
  }
}

class OfficeEventsPage extends StatelessWidget {
  const OfficeEventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          const Text('Gestion des événements'),
          const SizedBox(height: 8),
          const Text('Organisez des événements ici'),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Créer un événement...')),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Créer un événement'),
          ),
        ],
      ),
    );
  }
}

class OfficeFinancePage extends StatelessWidget {
  const OfficeFinancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Gestion financière',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _showAddIncomeDialog(context),
                    icon: const Icon(Icons.add_circle),
                    label: const Text('Revenu'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _showAddExpenseDialog(context),
                    icon: const Icon(Icons.remove_circle),
                    label: const Text('Dépense'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          BlocBuilder<FinanceBloc, FinanceState>(
            builder: (context, state) {
              if (state is FinanceLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is FinanceLoaded) {
                return Column(
                  children: [
                    _buildFinanceCard(
                      context,
                      'Budget annuel',
                      '${state.budget.toStringAsFixed(2)} €',
                      Icons.account_balance_wallet,
                      Colors.blue,
                    ),
                    _buildFinanceCard(
                      context,
                      'Solde actuel',
                      '${state.currentBalance.toStringAsFixed(2)} €',
                      state.currentBalance >= 0 ? Icons.trending_up : Icons.trending_down,
                      state.currentBalance >= 0 ? Colors.green : Colors.red,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Dernières transactions',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    ...state.transactions.take(10).map((transaction) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Icon(
                              transaction.type == TransactionType.income
                                  ? Icons.arrow_downward
                                  : Icons.arrow_upward,
                              color: transaction.type == TransactionType.income
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            title: Text(transaction.description),
                            subtitle: Text('${transaction.category} • ${transaction.date.day}/${transaction.date.month}/${transaction.date.year}'),
                            trailing: Text(
                              '${transaction.type == TransactionType.income ? '+' : '-'}${transaction.amount.toStringAsFixed(2)} €',
                              style: TextStyle(
                                color: transaction.type == TransactionType.income
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )),
                  ],
                );
              }

              return const Center(child: Text('Erreur de chargement'));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFinanceCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddIncomeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddTransactionDialog(type: TransactionType.income),
    );
  }

  void _showAddExpenseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddTransactionDialog(type: TransactionType.expense),
    );
  }
}

class AddTransactionDialog extends StatefulWidget {
  final TransactionType type;

  const AddTransactionDialog({super.key, required this.type});

  @override
  State<AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _category = 'Cotisation';

  final List<String> _incomeCategories = ['Cotisation', 'Subvention', 'Don', 'Sponsoring'];
  final List<String> _expenseCategories = ['Équipement', 'Location', 'Salaires', 'Frais divers'];

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = widget.type == TransactionType.income ? _incomeCategories : _expenseCategories;

    return AlertDialog(
      title: Text(widget.type == TransactionType.income ? 'Ajouter un revenu' : 'Ajouter une dépense'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Montant (€)'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Requis';
                if (double.tryParse(value) == null) return 'Montant invalide';
                return null;
              },
            ),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(labelText: 'Catégorie'),
              items: categories
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _category = value!;
                });
              },
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 2,
              validator: (value) => value?.isEmpty ?? true ? 'Requis' : null,
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
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final amount = double.parse(_amountController.text);
              if (widget.type == TransactionType.income) {
                context.read<FinanceBloc>().add(
                      AddIncome(
                        category: _category,
                        amount: amount,
                        description: _descriptionController.text,
                      ),
                    );
              } else {
                context.read<FinanceBloc>().add(
                      AddExpense(
                        category: _category,
                        amount: amount,
                        description: _descriptionController.text,
                      ),
                    );
              }
              Navigator.pop(context);
            }
          },
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }
}
