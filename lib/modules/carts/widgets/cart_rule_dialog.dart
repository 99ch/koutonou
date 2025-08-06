import 'package:flutter/material.dart';
import '../models/cart_rule_model.dart';

class CartRuleDialog extends StatefulWidget {
  final CartRule? cartRule;
  final Function(CartRule) onSave;

  const CartRuleDialog({super.key, this.cartRule, required this.onSave});

  @override
  State<CartRuleDialog> createState() => _CartRuleDialogState();
}

class _CartRuleDialogState extends State<CartRuleDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _codeController = TextEditingController();
  final _quantityController = TextEditingController();
  final _quantityPerUserController = TextEditingController();
  final _priorityController = TextEditingController();
  final _partialUseController = TextEditingController();
  final _minimumAmountController = TextEditingController();
  final _reductionPercentController = TextEditingController();
  final _reductionAmountController = TextEditingController();
  final _reductionTaxController = TextEditingController();
  final _reductionCurrencyController = TextEditingController();
  final _reductionProductController = TextEditingController();
  final _reductionExcludeSpecialController = TextEditingController();
  final _giftProductController = TextEditingController();
  final _giftProductAttributeController = TextEditingController();

  bool _active = true;
  bool _highlightCart = false;
  bool _partialUseBool = true;
  bool _minimumAmountTax = false;
  bool _minimumAmountCurrency = false;
  bool _minimumAmountShipping = false;
  bool _countryRestriction = false;
  bool _carrierRestriction = false;
  bool _groupRestriction = false;
  bool _cartRuleRestriction = false;
  bool _productRestriction = false;
  bool _shopRestriction = false;
  bool _freeShipping = false;
  bool _reductionTaxBool = false;
  bool _reductionExcludeSpecialBool = false;

  DateTime? _dateFrom;
  DateTime? _dateTo;

  @override
  void initState() {
    super.initState();
    if (widget.cartRule != null) {
      _populateFields(widget.cartRule!);
    } else {
      // Valeurs par défaut pour une nouvelle règle
      _quantityController.text = '1';
      _quantityPerUserController.text = '1';
      _priorityController.text = '1';
      _partialUseController.text = '1';
      _reductionTaxController.text = '1';
      _reductionCurrencyController.text = '1';
      _reductionExcludeSpecialController.text = '1';

      // Dates par défaut : aujourd'hui et dans 30 jours
      _dateFrom = DateTime.now();
      _dateTo = DateTime.now().add(const Duration(days: 30));
    }
  }

  void _populateFields(CartRule cartRule) {
    _nameController.text =
        cartRule.name['1'] ??
        (cartRule.name.values.isNotEmpty ? cartRule.name.values.first : '');
    _descriptionController.text = cartRule.description ?? '';
    _codeController.text = cartRule.code ?? '';
    _quantityController.text = cartRule.quantity?.toString() ?? '1';
    _quantityPerUserController.text =
        cartRule.quantityPerUser?.toString() ?? '1';
    _priorityController.text = cartRule.priority?.toString() ?? '1';
    _partialUseController.text = cartRule.partialUse.toString();
    _minimumAmountController.text = cartRule.minimumAmount?.toString() ?? '';
    _reductionPercentController.text =
        cartRule.reductionPercent?.toString() ?? '';
    _reductionAmountController.text =
        cartRule.reductionAmount?.toString() ?? '';
    _reductionTaxController.text = cartRule.reductionTax.toString();
    _reductionCurrencyController.text =
        cartRule.reductionCurrency?.toString() ?? '1';
    _reductionProductController.text =
        cartRule.reductionProduct?.toString() ?? '';
    _reductionExcludeSpecialController.text = cartRule.reductionExcludeSpecial
        .toString();
    _giftProductController.text = cartRule.giftProduct?.toString() ?? '';
    _giftProductAttributeController.text =
        cartRule.giftProductAttribute?.toString() ?? '';

    _active = cartRule.active;
    _highlightCart = cartRule.highlight;
    _partialUseBool = cartRule.partialUse;
    _minimumAmountTax = cartRule.minimumAmountTax;
    _minimumAmountCurrency =
        cartRule.minimumAmountCurrency != null &&
        cartRule.minimumAmountCurrency! > 0;
    _minimumAmountShipping = cartRule.minimumAmountShipping;
    _countryRestriction = cartRule.countryRestriction;
    _carrierRestriction = cartRule.carrierRestriction;
    _groupRestriction = cartRule.groupRestriction;
    _cartRuleRestriction = cartRule.cartRuleRestriction;
    _productRestriction = cartRule.productRestriction;
    _shopRestriction = cartRule.shopRestriction;
    _freeShipping = cartRule.freeShipping;
    _reductionTaxBool = cartRule.reductionTax;
    _reductionExcludeSpecialBool = cartRule.reductionExcludeSpecial;

    _dateFrom = cartRule.dateFrom;
    _dateTo = cartRule.dateTo;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _codeController.dispose();
    _quantityController.dispose();
    _quantityPerUserController.dispose();
    _priorityController.dispose();
    _partialUseController.dispose();
    _minimumAmountController.dispose();
    _reductionPercentController.dispose();
    _reductionAmountController.dispose();
    _reductionTaxController.dispose();
    _reductionCurrencyController.dispose();
    _reductionProductController.dispose();
    _reductionExcludeSpecialController.dispose();
    _giftProductController.dispose();
    _giftProductAttributeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFromDate
          ? (_dateFrom ?? DateTime.now())
          : (_dateTo ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isFromDate) {
          _dateFrom = picked;
        } else {
          _dateTo = picked;
        }
      });
    }
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      // Validation des dates
      if (_dateFrom == null || _dateTo == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Les dates de début et de fin sont requises'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final cartRule = CartRule(
        id: widget.cartRule?.id,
        name: {'1': _nameController.text},
        description: _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : null,
        code: _codeController.text.isNotEmpty ? _codeController.text : null,
        quantity: int.tryParse(_quantityController.text) ?? 1,
        quantityPerUser: int.tryParse(_quantityPerUserController.text) ?? 1,
        priority: int.tryParse(_priorityController.text) ?? 1,
        partialUse: _partialUseBool,
        minimumAmount: double.tryParse(_minimumAmountController.text),
        minimumAmountTax: _minimumAmountTax,
        minimumAmountCurrency: _minimumAmountCurrency ? 1 : null,
        minimumAmountShipping: _minimumAmountShipping,
        countryRestriction: _countryRestriction,
        carrierRestriction: _carrierRestriction,
        groupRestriction: _groupRestriction,
        cartRuleRestriction: _cartRuleRestriction,
        productRestriction: _productRestriction,
        shopRestriction: _shopRestriction,
        freeShipping: _freeShipping,
        reductionPercent: double.tryParse(_reductionPercentController.text),
        reductionAmount: double.tryParse(_reductionAmountController.text),
        reductionTax: _reductionTaxBool,
        reductionCurrency: int.tryParse(_reductionCurrencyController.text) ?? 1,
        reductionProduct: int.tryParse(_reductionProductController.text),
        reductionExcludeSpecial: _reductionExcludeSpecialBool,
        giftProduct: int.tryParse(_giftProductController.text),
        giftProductAttribute: int.tryParse(
          _giftProductAttributeController.text,
        ),
        active: _active,
        dateFrom: _dateFrom!,
        dateTo: _dateTo!,
        highlight: _highlightCart,
        dateAdd: widget.cartRule?.dateAdd,
        dateUpd: widget.cartRule?.dateUpd,
      );

      widget.onSave(cartRule);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.cartRule == null
            ? 'Nouvelle promotion'
            : 'Modifier la promotion',
      ),
      content: SizedBox(
        width: 600,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Informations générales
                const Text(
                  'Informations générales',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom *',
                    hintText: 'Nom de la promotion',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Le nom est requis';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Description de la promotion (optionnel)',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _codeController,
                  decoration: const InputDecoration(
                    labelText: 'Code promo',
                    hintText: 'Code de réduction (optionnel)',
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _quantityController,
                        decoration: const InputDecoration(
                          labelText: 'Quantité *',
                          hintText: '1',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Quantité requise';
                          }
                          final quantity = int.tryParse(value);
                          if (quantity == null || quantity <= 0) {
                            return 'Quantité invalide';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _quantityPerUserController,
                        decoration: const InputDecoration(
                          labelText: 'Quantité par utilisateur *',
                          hintText: '1',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Quantité par utilisateur requise';
                          }
                          final quantity = int.tryParse(value);
                          if (quantity == null || quantity <= 0) {
                            return 'Quantité invalide';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _priorityController,
                  decoration: const InputDecoration(
                    labelText: 'Priorité *',
                    hintText: '1',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Priorité requise';
                    }
                    final priority = int.tryParse(value);
                    if (priority == null || priority <= 0) {
                      return 'Priorité invalide';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Dates de validité
                const Divider(),
                const Text(
                  'Période de validité',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: const Text('Date de début'),
                        subtitle: Text(
                          _dateFrom != null
                              ? '${_dateFrom!.day}/${_dateFrom!.month}/${_dateFrom!.year}'
                              : 'Aucune date sélectionnée',
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () => _selectDate(context, true),
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        title: const Text('Date de fin'),
                        subtitle: Text(
                          _dateTo != null
                              ? '${_dateTo!.day}/${_dateTo!.month}/${_dateTo!.year}'
                              : 'Aucune date sélectionnée',
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () => _selectDate(context, false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Conditions
                const Divider(),
                const Text(
                  'Conditions',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),

                TextFormField(
                  controller: _minimumAmountController,
                  decoration: const InputDecoration(
                    labelText: 'Montant minimum',
                    hintText: 'Montant minimum requis (optionnel)',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final amount = double.tryParse(value);
                      if (amount == null || amount < 0) {
                        return 'Montant minimum invalide';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Réductions
                const Divider(),
                const Text(
                  'Réductions',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _reductionPercentController,
                        decoration: const InputDecoration(
                          labelText: 'Réduction en %',
                          hintText: '10.5',
                          suffixText: '%',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            final percent = double.tryParse(value);
                            if (percent == null ||
                                percent < 0 ||
                                percent > 100) {
                              return 'Pourcentage invalide (0-100)';
                            }
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _reductionAmountController,
                        decoration: const InputDecoration(
                          labelText: 'Réduction en montant',
                          hintText: '15.50',
                          suffixText: '€',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            final amount = double.tryParse(value);
                            if (amount == null || amount < 0) {
                              return 'Montant invalide';
                            }
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Options principales
                const Divider(),
                const Text(
                  'Options',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),

                CheckboxListTile(
                  title: const Text('Promotion active'),
                  value: _active,
                  onChanged: (bool? value) {
                    setState(() {
                      _active = value ?? true;
                    });
                  },
                ),

                CheckboxListTile(
                  title: const Text('Livraison gratuite'),
                  value: _freeShipping,
                  onChanged: (bool? value) {
                    setState(() {
                      _freeShipping = value ?? false;
                    });
                  },
                ),

                CheckboxListTile(
                  title: const Text('Utilisation partielle'),
                  subtitle: const Text(
                    'Permet d\'utiliser partiellement le bon',
                  ),
                  value: _partialUseBool,
                  onChanged: (bool? value) {
                    setState(() {
                      _partialUseBool = value ?? true;
                    });
                  },
                ),

                CheckboxListTile(
                  title: const Text('Mettre en évidence dans le panier'),
                  value: _highlightCart,
                  onChanged: (bool? value) {
                    setState(() {
                      _highlightCart = value ?? false;
                    });
                  },
                ),

                CheckboxListTile(
                  title: const Text('Exclure les promotions spéciales'),
                  value: _reductionExcludeSpecialBool,
                  onChanged: (bool? value) {
                    setState(() {
                      _reductionExcludeSpecialBool = value ?? false;
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
          child: Text(widget.cartRule == null ? 'Créer' : 'Modifier'),
        ),
      ],
    );
  }
}
