import 'package:flutter/material.dart';
import '../models/order_model.dart';

/// Widget pour les actions sur une commande
class OrderActions extends StatelessWidget {
  final Order order;
  final Function(int)? onStateChanged;

  const OrderActions({super.key, required this.order, this.onStateChanged});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            Row(
              children: [
                Icon(
                  Icons.settings,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Actions',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Actions principales
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // Changer l'état
                if (onStateChanged != null)
                  _buildActionButton(
                    context,
                    'Changer l\'état',
                    Icons.edit,
                    () => _showStateChanger(context),
                    color: Theme.of(context).colorScheme.primary,
                  ),

                // Générer facture
                _buildActionButton(
                  context,
                  'Générer facture',
                  Icons.receipt_long,
                  () => _generateInvoice(context),
                  color: Colors.green,
                ),

                // Générer bon de livraison
                _buildActionButton(
                  context,
                  'Bon de livraison',
                  Icons.description,
                  () => _generateDeliveryNote(context),
                  color: Colors.blue,
                ),

                // Envoyer email
                _buildActionButton(
                  context,
                  'Envoyer email',
                  Icons.email,
                  () => _sendEmail(context),
                  color: Colors.orange,
                ),

                // Imprimer étiquette
                _buildActionButton(
                  context,
                  'Étiquette',
                  Icons.local_shipping,
                  () => _printShippingLabel(context),
                  color: Colors.indigo,
                ),

                // Exporter
                _buildActionButton(
                  context,
                  'Exporter',
                  Icons.download,
                  () => _exportOrder(context),
                  color: Colors.grey,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Actions de gestion
            const Divider(),
            const SizedBox(height: 8),

            Text(
              'Gestion',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _duplicateOrder(context),
                    icon: const Icon(Icons.copy),
                    label: const Text('Dupliquer'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _addNote(context),
                    icon: const Icon(Icons.note_add),
                    label: const Text('Ajouter note'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Actions dangereuses
            ExpansionTile(
              title: const Text(
                'Actions avancées',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
              leading: const Icon(Icons.warning, color: Colors.red),
              children: [
                ListTile(
                  leading: const Icon(Icons.cancel, color: Colors.red),
                  title: const Text('Annuler la commande'),
                  onTap: () => _cancelOrder(context),
                ),
                ListTile(
                  leading: const Icon(Icons.undo, color: Colors.orange),
                  title: const Text('Rembourser'),
                  onTap: () => _refundOrder(context),
                ),
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: const Text('Supprimer'),
                  onTap: () => _deleteOrder(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onPressed, {
    Color? color,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color?.withOpacity(0.1),
        foregroundColor: color,
        side: BorderSide(color: color ?? Colors.grey),
      ),
    );
  }

  void _showStateChanger(BuildContext context) {
    // Cette fonction sera appelée depuis le parent
    // qui a accès aux états disponibles
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Changer l\'état'),
        content: const Text(
          'Cette action doit être gérée par le widget parent avec accès aux états.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _generateInvoice(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Génération de facture à implémenter'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _generateDeliveryNote(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Génération du bon de livraison à implémenter'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _sendEmail(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Envoyer un email'),
        content: const Text('Quel type d\'email souhaitez-vous envoyer ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Email de confirmation envoyé'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Confirmation'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Email de suivi envoyé'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Suivi'),
          ),
        ],
      ),
    );
  }

  void _printShippingLabel(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Impression d\'étiquette à implémenter'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _exportOrder(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exporter la commande'),
        content: const Text('Dans quel format souhaitez-vous exporter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Export PDF à implémenter'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text('PDF'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Export CSV à implémenter'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text('CSV'),
          ),
        ],
      ),
    );
  }

  void _duplicateOrder(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dupliquer la commande'),
        content: Text(
          'Voulez-vous créer une nouvelle commande basée sur ${order.reference} ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Duplication de commande à implémenter'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text('Dupliquer'),
          ),
        ],
      ),
    );
  }

  void _addNote(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter une note'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Votre note...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Note ajoutée avec succès'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  void _cancelOrder(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler la commande'),
        content: Text(
          'Êtes-vous sûr de vouloir annuler la commande ${order.reference} ?\n\n'
          'Cette action ne peut pas être annulée.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Non'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.of(context).pop();
              if (onStateChanged != null) {
                onStateChanged!(6); // État "Annulée"
              }
            },
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );
  }

  void _refundOrder(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rembourser la commande'),
        content: Text(
          'Voulez-vous rembourser la commande ${order.reference} ?\n\n'
          'Montant: ${order.totalPaid.toStringAsFixed(2)} €',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () {
              Navigator.of(context).pop();
              if (onStateChanged != null) {
                onStateChanged!(7); // État "Remboursée"
              }
            },
            child: const Text('Rembourser'),
          ),
        ],
      ),
    );
  }

  void _deleteOrder(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la commande'),
        content: Text(
          'ATTENTION: Voulez-vous vraiment supprimer définitivement la commande ${order.reference} ?\n\n'
          'Cette action est irréversible et supprimera toutes les données associées.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Suppression de commande à implémenter'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Supprimer définitivement'),
          ),
        ],
      ),
    );
  }
}
