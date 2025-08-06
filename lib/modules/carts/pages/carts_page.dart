import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../models/cart_model.dart';
import '../widgets/cart_card.dart';
import '../widgets/cart_rule_card.dart';
import '../widgets/cart_dialog.dart';
import '../widgets/cart_rule_dialog.dart';

class CartsPage extends StatefulWidget {
  const CartsPage({Key? key}) : super(key: key);

  @override
  State<CartsPage> createState() => _CartsPageState();
}

class _CartsPageState extends State<CartsPage> with TickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      cartProvider.loadCarts();
      cartProvider.loadActiveCartRules();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paniers & Promotions'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Paniers', icon: Icon(Icons.shopping_cart)),
            Tab(text: 'Promotions', icon: Icon(Icons.local_offer)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final cartProvider = Provider.of<CartProvider>(
                context,
                listen: false,
              );
              cartProvider.loadCarts();
              cartProvider.loadCartRules();
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildCartsTab(), _buildPromotionsTab()],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCartsTab() {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        if (cartProvider.isLoadingCarts) {
          return const Center(child: CircularProgressIndicator());
        }

        if (cartProvider.cartsError != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  'Erreur de chargement',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  cartProvider.cartsError!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => cartProvider.loadCarts(),
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          );
        }

        if (cartProvider.carts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Aucun panier trouvé',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Créez votre premier panier',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Rechercher un panier...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  // TODO: Implement search functionality
                },
              ),
            ),

            // Carts list
            Expanded(
              child: ListView.builder(
                itemCount: cartProvider.carts.length,
                itemBuilder: (context, index) {
                  final cart = cartProvider.carts[index];
                  return CartCard(
                    cart: cart,
                    onTap: () => _showCartDetails(context, cart),
                    onEdit: () => _showEditCartDialog(context, cart),
                    onDelete: () => _showDeleteConfirmation(context, cart),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPromotionsTab() {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        if (cartProvider.isLoadingCartRules) {
          return const Center(child: CircularProgressIndicator());
        }

        if (cartProvider.cartRulesError != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  'Erreur de chargement',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  cartProvider.cartRulesError!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => cartProvider.loadCartRules(),
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          );
        }

        final activePromotions = cartProvider.activeCartRules;
        final allPromotions = cartProvider.cartRules;

        return DefaultTabController(
          length: 2,
          child: Column(
            children: [
              const TabBar(
                tabs: [
                  Tab(text: 'Actives'),
                  Tab(text: 'Toutes'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildPromotionsList(activePromotions, true),
                    _buildPromotionsList(allPromotions, false),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPromotionsList(List cartRules, bool showApplyButton) {
    if (cartRules.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_offer_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              showApplyButton
                  ? 'Aucune promotion active'
                  : 'Aucune promotion trouvée',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      itemCount: cartRules.length,
      itemBuilder: (context, index) {
        final cartRule = cartRules[index];
        return CartRuleCard(
          cartRule: cartRule,
          onTap: () => _showPromotionDetails(context, cartRule),
          onEdit: () => _showEditPromotionDialog(context, cartRule),
          onDelete: () => _showDeletePromotionConfirmation(context, cartRule),
          onApply: showApplyButton
              ? () => _applyPromotion(context, cartRule)
              : null,
          showApplyButton: showApplyButton,
        );
      },
    );
  }

  void _showCreateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Créer'),
        content: const Text('Que voulez-vous créer ?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showCreateCartDialog(context);
            },
            child: const Text('Nouveau panier'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showCreatePromotionDialog(context);
            },
            child: const Text('Nouvelle promotion'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }

  void _showCreateCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CartDialog(
        onSave: (cart) async {
          final provider = Provider.of<CartProvider>(context, listen: false);
          final success = await provider.createCart(cart);
          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Panier créé avec succès')),
            );
          } else if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Erreur: ${provider.cartsError ?? 'Erreur inconnue'}',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      ),
    );
  }

  void _showEditCartDialog(BuildContext context, Cart cart) {
    showDialog(
      context: context,
      builder: (context) => CartDialog(
        cart: cart,
        onSave: (updatedCart) async {
          final provider = Provider.of<CartProvider>(context, listen: false);
          final success = await provider.updateCart(updatedCart);
          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Panier modifié avec succès')),
            );
          } else if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Erreur: ${provider.cartsError ?? 'Erreur inconnue'}',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      ),
    );
  }

  void _showCartDetails(BuildContext context, Cart cart) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Panier #${cart.id}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Client ID: ${cart.idCustomer ?? 'N/A'}'),
              Text('Devise ID: ${cart.idCurrency}'),
              Text('Langue ID: ${cart.idLang}'),
              Text('Articles: ${cart.totalItems}'),
              Text('Quantité totale: ${cart.totalQuantity.toInt()}'),
              if (cart.gift) Text('Cadeau: Oui'),
              if (cart.hasGiftMessage) Text('Message: ${cart.giftMessage}'),
              if (cart.recyclable) Text('Recyclable: Oui'),
              if (cart.secureKey != null) Text('Clé: ${cart.secureKey}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Cart cart) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Voulez-vous vraiment supprimer le panier #${cart.id} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final cartProvider = Provider.of<CartProvider>(
                context,
                listen: false,
              );
              cartProvider.deleteCart(cart.id!);
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showCreatePromotionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CartRuleDialog(
        onSave: (cartRule) async {
          final provider = Provider.of<CartProvider>(context, listen: false);
          final success = await provider.createCartRule(cartRule);
          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Promotion créée avec succès')),
            );
          } else if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Erreur: ${provider.cartRulesError ?? 'Erreur inconnue'}',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      ),
    );
  }

  void _showEditPromotionDialog(BuildContext context, cartRule) {
    showDialog(
      context: context,
      builder: (context) => CartRuleDialog(
        cartRule: cartRule,
        onSave: (updatedCartRule) async {
          final provider = Provider.of<CartProvider>(context, listen: false);
          final success = await provider.updateCartRule(updatedCartRule);
          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Promotion modifiée avec succès')),
            );
          } else if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Erreur: ${provider.cartRulesError ?? 'Erreur inconnue'}',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      ),
    );
  }

  void _showPromotionDetails(BuildContext context, cartRule) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          cartRule.getNameForLanguage('1').isNotEmpty
              ? cartRule.getNameForLanguage('1')
              : 'Promotion #${cartRule.id}',
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (cartRule.description != null)
                Text('Description: ${cartRule.description}'),
              Text('Actif: ${cartRule.active ? 'Oui' : 'Non'}'),
              Text('Valide du ${cartRule.dateFrom} au ${cartRule.dateTo}'),
              if (cartRule.hasCode) Text('Code: ${cartRule.code}'),
              if (cartRule.hasPercentageDiscount)
                Text('Réduction: ${cartRule.reductionPercent}%'),
              if (cartRule.hasAmountDiscount)
                Text('Réduction: ${cartRule.reductionAmount}€'),
              if (cartRule.freeShipping) Text('Livraison gratuite: Oui'),
              if (cartRule.hasMinimumAmount)
                Text('Montant minimum: ${cartRule.minimumAmount}€'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showDeletePromotionConfirmation(BuildContext context, cartRule) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Voulez-vous vraiment supprimer cette promotion ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final cartProvider = Provider.of<CartProvider>(
                context,
                listen: false,
              );
              cartProvider.deleteCartRule(cartRule.id!);
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _applyPromotion(BuildContext context, cartRule) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    if (cartRule.hasCode) {
      cartProvider.applyPromotionCode(cartRule.code!).then((success) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Promotion appliquée avec succès')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                cartProvider.cartRulesError ?? 'Erreur lors de l\'application',
              ),
            ),
          );
        }
      });
    }
  }
}
