import 'dart:async';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'premium_manager.dart';
import 'analytics_service.dart';

class PurchaseService {
  static const String _productId = 'fincalc_pro_premium';
  static final PurchaseService _instance = PurchaseService._();
  factory PurchaseService() => _instance;
  PurchaseService._();

  late StreamSubscription<List<PurchaseDetails>> _subscription;
  bool _available = false;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    _available = await InAppPurchase.instance.isAvailable();
    if (!_available) return;

    _subscription = InAppPurchase.instance.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => _subscription.cancel(),
    );
  }

  void dispose() => _subscription.cancel();

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.productID == _productId) {
        if (purchase.status == PurchaseStatus.purchased ||
            purchase.status == PurchaseStatus.restored) {
          await PremiumManager.setPremium(true);
          if (purchase.status == PurchaseStatus.purchased) {
            await AnalyticsService.logPremiumPurchased();
          } else {
            await AnalyticsService.logPremiumRestored();
          }
        }
        if (purchase.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(purchase);
        }
      }
    }
  }

  Future<bool> get isAvailable async => _available;

  /// Fetches product details. Returns null if store unavailable.
  Future<ProductDetails?> fetchProductDetails() async {
    if (!_available) return null;
    final response = await InAppPurchase.instance.queryProductDetails({_productId});
    if (response.productDetails.isEmpty) return null;
    return response.productDetails.first;
  }

  /// Initiates the Rs.99 premium purchase.
  Future<void> buyPremium(BuildContext context) async {
    if (!_available) {
      _showError(context, 'Store not available. Please try again later.');
      return;
    }
    final product = await fetchProductDetails();
    if (product == null) {
      _showError(context, 'Product not found. Please try again later.');
      return;
    }
    final param = PurchaseParam(productDetails: product);
    await InAppPurchase.instance.buyNonConsumable(purchaseParam: param);
  }

  /// Restores previous purchases.
  Future<void> restorePurchases(BuildContext context) async {
    if (!_available) {
      _showError(context, 'Store not available.');
      return;
    }
    await InAppPurchase.instance.restorePurchases();
  }

  void _showError(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
