import 'package:flutter/foundation.dart';

/// How a field renders and edits.
enum ColKind { text, number, money, email, longText, select }

@immutable
class FieldSpec {
  const FieldSpec(
    this.field,
    this.title,
    this.kind, {
    this.inList = true,
    this.editable = true,
    this.options = const [],
  });

  final String field;
  final String title;
  final ColKind kind;
  final bool inList;
  final bool editable;
  final List<String> options;
}

@immutable
class ResourceSpec {
  const ResourceSpec({
    required this.name,
    required this.singular,
    required this.titleField,
    required this.fields,
    required this.statuses,
  });

  final String name;
  final String singular;

  /// Which field names a record in headings, drawers and breadcrumbs.
  final String titleField;
  final List<FieldSpec> fields;
  final List<String> statuses;

  List<FieldSpec> get listFields => [
    for (final f in fields)
      if (f.inList) f,
  ];
  List<FieldSpec> get editableFields => [
    for (final f in fields)
      if (f.editable) f,
  ];
}

/// One declarative spec per resource is what lets a single set of screens serve
/// orders, customers and products instead of three near-identical copies.
const kResources = <String, ResourceSpec>{
  'orders': ResourceSpec(
    name: 'orders',
    singular: 'Order',
    titleField: 'reference',
    statuses: ['Paid', 'Pending', 'Refunded', 'Shipped', 'Cancelled'],
    fields: [
      FieldSpec('reference', 'Order', ColKind.text, editable: false),
      FieldSpec('customer', 'Customer', ColKind.text),
      FieldSpec(
        'status',
        'Status',
        ColKind.select,
        options: ['Paid', 'Pending', 'Refunded', 'Shipped', 'Cancelled'],
      ),
      FieldSpec('items', 'Items', ColKind.number),
      FieldSpec('total', 'Total', ColKind.money),
      FieldSpec('date', 'Date', ColKind.text),
      FieldSpec('notes', 'Notes', ColKind.longText, inList: false),
    ],
  ),
  'customers': ResourceSpec(
    name: 'customers',
    singular: 'Customer',
    titleField: 'name',
    statuses: ['Active', 'Churned'],
    fields: [
      FieldSpec('name', 'Name', ColKind.text),
      FieldSpec('email', 'Email', ColKind.email),
      FieldSpec('orders', 'Orders', ColKind.number, editable: false),
      FieldSpec('spend', 'Lifetime spend', ColKind.money, editable: false),
      FieldSpec(
        'status',
        'Status',
        ColKind.select,
        options: ['Active', 'Churned'],
      ),
      FieldSpec('notes', 'Notes', ColKind.longText, inList: false),
    ],
  ),
  'products': ResourceSpec(
    name: 'products',
    singular: 'Product',
    titleField: 'name',
    statuses: ['In stock', 'Low', 'Out of stock'],
    fields: [
      FieldSpec('name', 'Product', ColKind.text),
      FieldSpec('sku', 'SKU', ColKind.text),
      FieldSpec('price', 'Price', ColKind.money),
      FieldSpec('stock', 'Stock', ColKind.number),
      FieldSpec(
        'status',
        'Status',
        ColKind.select,
        options: ['In stock', 'Low', 'Out of stock'],
      ),
      FieldSpec('notes', 'Notes', ColKind.longText, inList: false),
    ],
  ),
};
