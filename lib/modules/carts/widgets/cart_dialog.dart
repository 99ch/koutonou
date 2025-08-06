import 'package:flutter/material.dart';
import '../models/cart_model.dart';

class CartDialog extends StatefulWidget {
  final Cart? cart;
  final Function(Cart) onSave;

  const CartDialog({super.key, this.cart, required this.onSave});

  @override
  State<CartDialog> createState() => _CartDialogState();
}

class _CartDialogState extends State<CartDialog> {
  final _formKey = GlobalKey<FormState>();
  final _customerIdController = TextEditingController();
  final _addressDeliveryIdController = TextEditingController();
  final _addressInvoiceIdController = TextEditingController();
  final _currencyIdController = TextEditingController();
  final _langIdController = TextEditingController();
  final _carrierIdController = TextEditingController();

  bool _recycled = false;
  bool _gift = false;
  bool _mobileTheme = false;
  bool _allowSeparatedPackage = false;

  @override
  void initState() {
    super.initState();
    if (widget.cart != null) {
      _populateFields(widget.cart!);
    } else {
      // Valeurs par défaut pour un nouveau panier
      _currencyIdController.text = '1';
      _langIdController.text = '1';
      _carrierIdController.text = '1';
    }
  }

  void _populateFields(Cart cart) {
    _customerIdController.text = cart.idCustomer?.toString() ?? '';
    _addressDeliveryIdController.text =
        cart.idAddressDelivery?.toString() ?? '';
    _addressInvoiceIdController.text = cart.idAddressInvoice?.toString() ?? '';
    _currencyIdController.text = cart.idCurrency.toString();
    _langIdController.text = cart.idLang.toString();
    _carrierIdController.text = cart.idCarrier?.toString() ?? '1';
    _recycled = cart.recyclable;
    _gift = cart.gift;
    _mobileTheme = cart.mobileTheme;
    _allowSeparatedPackage = cart.allowSeperatedPackage;
  }

  @override
  void dispose() {
    _customerIdController.dispose();
    _addressDeliveryIdController.dispose();
    _addressInvoiceIdController.dispose();
    _currencyIdController.dispose();
    _langIdController.dispose();
    _carrierIdController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      final cart = Cart(
        id: widget.cart?.id,
        idCustomer: int.tryParse(_customerIdController.text),
        idAddressDelivery: int.tryParse(_addressDeliveryIdController.text),
        idAddressInvoice: int.tryParse(_addressInvoiceIdController.text),
        idCurrency: int.tryParse(_currencyIdController.text) ?? 1,
        idLang: int.tryParse(_langIdController.text) ?? 1,
        idCarrier: int.tryParse(_carrierIdController.text),
        recyclable: _recycled,
        gift: _gift,
        mobileTheme: _mobileTheme,
        allowSeperatedPackage: _allowSeparatedPackage,
        dateAdd: widget.cart?.dateAdd,
        dateUpd: widget.cart?.dateUpd,
        // Conserve les autres champs existants
        secureKey: widget.cart?.secureKey,
        giftMessage: widget.cart?.giftMessage,
        deliveryOption: widget.cart?.deliveryOption,
        idGuest: widget.cart?.idGuest,
        idShopGroup: widget.cart?.idShopGroup,
        idShop: widget.cart?.idShop,
        cartRows: widget.cart?.cartRows,
      );

      widget.onSave(cart);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.cart == null ? 'Nouveau panier' : 'Modifier le panier',
      ),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Customer ID
                TextFormField(
                  controller: _customerIdController,
                  decoration: const InputDecoration(
                    labelText: 'ID Client',
                    hintText: 'ID du client (optionnel)',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final id = int.tryParse(value);
                      if (id == null || id <= 0) {
                        return 'ID client invalide';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Currency ID
                TextFormField(
                  controller: _currencyIdController,
                  decoration: const InputDecoration(
                    labelText: 'ID Devise *',
                    hintText: '1',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'ID devise requis';
                    }
                    final id = int.tryParse(value);
                    if (id == null || id <= 0) {
                      return 'ID devise invalide';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Language ID
                TextFormField(
                  controller: _langIdController,
                  decoration: const InputDecoration(
                    labelText: 'ID Langue *',
                    hintText: '1',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'ID langue requis';
                    }
                    final id = int.tryParse(value);
                    if (id == null || id <= 0) {
                      return 'ID langue invalide';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Carrier ID
                TextFormField(
                  controller: _carrierIdController,
                  decoration: const InputDecoration(
                    labelText: 'ID Transporteur',
                    hintText: '1',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final id = int.tryParse(value);
                      if (id == null || id <= 0) {
                        return 'ID transporteur invalide';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Address Delivery ID
                TextFormField(
                  controller: _addressDeliveryIdController,
                  decoration: const InputDecoration(
                    labelText: 'ID Adresse de livraison',
                    hintText: 'ID de l\'adresse de livraison (optionnel)',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final id = int.tryParse(value);
                      if (id == null || id <= 0) {
                        return 'ID adresse de livraison invalide';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Address Invoice ID
                TextFormField(
                  controller: _addressInvoiceIdController,
                  decoration: const InputDecoration(
                    labelText: 'ID Adresse de facturation',
                    hintText: 'ID de l\'adresse de facturation (optionnel)',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final id = int.tryParse(value);
                      if (id == null || id <= 0) {
                        return 'ID adresse de facturation invalide';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Options
                const Divider(),
                const Text(
                  'Options',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                CheckboxListTile(
                  title: const Text('Panier recyclé'),
                  value: _recycled,
                  onChanged: (bool? value) {
                    setState(() {
                      _recycled = value ?? false;
                    });
                  },
                ),

                CheckboxListTile(
                  title: const Text('Cadeau'),
                  value: _gift,
                  onChanged: (bool? value) {
                    setState(() {
                      _gift = value ?? false;
                    });
                  },
                ),

                CheckboxListTile(
                  title: const Text('Thème mobile'),
                  value: _mobileTheme,
                  onChanged: (bool? value) {
                    setState(() {
                      _mobileTheme = value ?? false;
                    });
                  },
                ),

                CheckboxListTile(
                  title: const Text('Permettre les colis séparés'),
                  value: _allowSeparatedPackage,
                  onChanged: (bool? value) {
                    setState(() {
                      _allowSeparatedPackage = value ?? false;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _handleSave,
          child: Text(widget.cart == null ? 'Créer' : 'Modifier'),
        ),
      ],
    );
  }
}
