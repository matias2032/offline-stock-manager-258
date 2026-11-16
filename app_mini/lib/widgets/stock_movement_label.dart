import 'package:mini/l10n/app_localizations.dart';

import '../models/stock_movement_model.dart';

/// Localized name of a movement type, shared by the stock screens.
String stockMovementLabel(AppLocalizations l10n, String movementType) {
  switch (movementType) {
    case StockMovementModel.typeInitial:
      return l10n.movementInitial;
    case StockMovementModel.typePurchase:
      return l10n.movementPurchase;
    case StockMovementModel.typeSale:
      return l10n.movementSale;
    case StockMovementModel.typeSaleReversal:
      return l10n.movementSaleReversal;
    case StockMovementModel.typeAdjustmentIn:
      return l10n.movementAdjustmentIn;
    case StockMovementModel.typeAdjustmentOut:
      return l10n.movementAdjustmentOut;
    case StockMovementModel.typeLoss:
      return l10n.movementLoss;
    default:
      return movementType;
  }
}