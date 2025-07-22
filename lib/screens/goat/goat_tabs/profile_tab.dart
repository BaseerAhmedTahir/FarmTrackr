import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:goat_tracker/models/goat.dart';
import 'package:goat_tracker/providers.dart';
import 'package:goat_tracker/widgets/editable_field.dart';
import 'package:goat_tracker/widgets/image_picker_widget.dart';

class GoatProfileTab extends ConsumerWidget {
  final Goat goat;
  final bool isEditing;

  const GoatProfileTab({
    super.key,
    required this.goat,
    this.isEditing = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final imageHeight = MediaQuery.of(context).size.height * 0.3;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photo Carousel
          if (goat.photoUrls.isNotEmpty) ...[
            CarouselSlider(
              options: CarouselOptions(
                height: imageHeight,
                viewportFraction: 1.0,
                enableInfiniteScroll: goat.photoUrls.length > 1,
              ),
              items: goat.photoUrls.map((url) {
                return Image.network(
                  url,
                  fit: BoxFit.cover,
                  width: double.infinity,
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],

                    if (isEditing)
            ImagePickerWidget(
              onImagePicked: (file) {
                // TODO: Implement photo upload
              },
            ),

          // QR Code
          Center(
            child: QrImageView(
              data: goat.id,
              version: QrVersions.auto,
              size: 150.0,
            ),
          ),
          const SizedBox(height: 16),

          // Basic Info Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Basic Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  EditableField(
                    label: 'Tag Number',
                    value: goat.tagNumber,
                    isEditing: isEditing,
                    onChanged: (value) {
                      // TODO: Update tag number
                    },
                  ),
                  EditableField(
                    label: 'Name',
                    value: goat.name,
                    isEditing: isEditing,
                    onChanged: (value) {
                      // TODO: Update name
                    },
                  ),
                  EditableField(
                    label: 'Birth Date',
                    value: dateFormat.format(goat.birthDate),
                    isEditing: isEditing,
                    onChanged: (value) {
                      // TODO: Update birth date
                    },
                  ),
                  EditableField(
                    label: 'Gender',
                    value: goat.gender.name.toUpperCase(),
                    isEditing: isEditing,
                    onChanged: (value) {
                      // TODO: Update gender
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Purchase Info Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Purchase Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  EditableField(
                    label: 'Purchase Price',
                    value: '\$${goat.price.toStringAsFixed(2)}',
                    isEditing: isEditing,
                    onChanged: (value) {
                      // TODO: Update purchase price
                    },
                  ),
                  if (goat.salePrice != null)
                    EditableField(
                      label: 'Sale Price',
                      value: '\$${goat.salePrice!.toStringAsFixed(2)}',
                      isEditing: isEditing,
                      onChanged: (value) {
                        // TODO: Update sale price
                      },
                    ),
                  EditableField(
                    label: 'Status',
                    value: goat.status.name.toUpperCase(),
                    isEditing: isEditing,
                    onChanged: (value) {
                      // TODO: Update status
                    },
                  ),
                ],
              ),
            ),
          ),
          if (isEditing) ...[
            ImagePickerWidget(
              onImagePicked: (file) {
                ref.read(goatServiceProvider).updateGoat(
                  goat,
                  newPhoto: file,
                );
              },
            ),
            const SizedBox(height: 16),
          ],

          // QR Code
          Center(
            child: Column(
              children: [
                QrImageView(
                  data: goat.qrCode,
                  version: QrVersions.auto,
                  size: 150.0,
                ),
                const SizedBox(height: 8),
                Text('Tag: ${goat.tagNumber}',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // Basic Information
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Basic Information',
                      style: Theme.of(context).textTheme.titleLarge),
                  const Divider(),
                  const SizedBox(height: 8),
                  EditableField(
                    label: 'Name',
                    value: goat.name,
                    isEditing: isEditing,
                    onChanged: (value) {
                      // Handle name update
                    },
                  ),
                  EditableField(
                    label: 'Breed',
                    value: goat.breed,
                    isEditing: isEditing,
                    onChanged: (value) {
                      // Handle breed update
                    },
                  ),
                  EditableField(
                    label: 'Gender',
                    value: goat.gender.name,
                    isEditing: isEditing,
                    onChanged: (value) {
                      // Handle gender update
                    },
                  ),
                  EditableField(
                    label: 'Date of Birth',
                    value: dateFormat.format(goat.birthDate),
                    isEditing: isEditing,
                    onChanged: (value) {
                      // Handle birth date update
                    },
                  ),
                  if (goat.color != null)
                    EditableField(
                      label: 'Color',
                      value: goat.color!,
                      isEditing: isEditing,
                      onChanged: (value) {
                        // Handle color update
                      },
                    ),
                  if (goat.markings != null)
                    EditableField(
                      label: 'Markings',
                      value: goat.markings!,
                      isEditing: isEditing,
                      onChanged: (value) {
                        // Handle markings update
                      },
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Purchase Information
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Purchase Information',
                      style: Theme.of(context).textTheme.titleLarge),
                  const Divider(),
                  const SizedBox(height: 8),
                  EditableField(
                    label: 'Purchase Date',
                    value: goat.purchaseDate != null
                        ? dateFormat.format(goat.purchaseDate!)
                        : 'Not recorded',
                    isEditing: isEditing,
                    onChanged: (value) {
                      // Handle purchase date update
                    },
                  ),
                  EditableField(
                    label: 'Purchase Price',
                    value: '\$${goat.price.toStringAsFixed(2)}',
                    isEditing: isEditing,
                    onChanged: (value) {
                      // Handle price update
                    },
                  ),
                  if (goat.vendorName != null)
                    EditableField(
                      label: 'Vendor Name',
                      value: goat.vendorName!,
                      isEditing: isEditing,
                      onChanged: (value) {
                        // Handle vendor name update
                      },
                    ),
                  if (goat.vendorContact != null)
                    EditableField(
                      label: 'Vendor Contact',
                      value: goat.vendorContact!,
                      isEditing: isEditing,
                      onChanged: (value) {
                        // Handle vendor contact update
                      },
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Status History
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Status History',
                      style: Theme.of(context).textTheme.titleLarge),
                  const Divider(),
                  const SizedBox(height: 8),
                  ...goat.statusLog.map((statusEntry) {
                    final timestamp = DateTime.parse(statusEntry['timestamp']);
                    return ListTile(
                      title: Text(
                          'Changed from ${statusEntry['from']} to ${statusEntry['to']}'),
                      subtitle: Text(dateFormat.format(timestamp)),
                      trailing: statusEntry['reason'] != null
                          ? Tooltip(
                              message: statusEntry['reason'],
                              child: const Icon(Icons.info_outline),
                            )
                          : null,
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
