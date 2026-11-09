import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/enums.dart';
import '../../l10n/app_localizations.dart';

enum ReceiptSource { camera, gallery, pdf }

/// A file chosen by the user, before it is stored.
class PickedReceipt {
  const PickedReceipt(this.file, this.kind);

  final File file;
  final ReceiptKind kind;
}

/// Takes a photo or picks a file. Behind an interface so tests never reach
/// the platform channels.
abstract class ReceiptPicker {
  /// Null when the user cancelled.
  Future<PickedReceipt?> pick(ReceiptSource source);
}

class PlatformReceiptPicker implements ReceiptPicker {
  PlatformReceiptPicker({ImagePicker? images})
    : _images = images ?? ImagePicker();

  final ImagePicker _images;

  @override
  Future<PickedReceipt?> pick(ReceiptSource source) async {
    switch (source) {
      case ReceiptSource.camera:
      case ReceiptSource.gallery:
        final shot = await _images.pickImage(
          source: source == ReceiptSource.camera
              ? ImageSource.camera
              : ImageSource.gallery,
        );
        return shot == null
            ? null
            : PickedReceipt(File(shot.path), ReceiptKind.photo);
      case ReceiptSource.pdf:
        final picked = await FilePicker.pickFile(
          type: FileType.custom,
          allowedExtensions: const ['pdf'],
        );
        final path = picked?.path;
        return path == null ? null : PickedReceipt(File(path), ReceiptKind.pdf);
    }
  }
}

final receiptPickerProvider = Provider<ReceiptPicker>(
  (ref) => PlatformReceiptPicker(),
);

/// The three buttons that add a receipt (camera, gallery, PDF).
class ReceiptButtons extends ConsumerWidget {
  const ReceiptButtons({
    super.key,
    required this.onPicked,
    this.enabled = true,
  });

  final ValueChanged<PickedReceipt> onPicked;
  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);

    Future<void> pick(ReceiptSource source) async {
      try {
        final picked = await ref.read(receiptPickerProvider).pick(source);
        if (picked != null) onPicked(picked);
      } catch (_) {
        messenger.showSnackBar(SnackBar(content: Text(l.expReceiptError)));
      }
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final (source, icon, label) in [
          (
            ReceiptSource.camera,
            Icons.photo_camera_outlined,
            l.expReceiptCamera,
          ),
          (
            ReceiptSource.gallery,
            Icons.photo_library_outlined,
            l.expReceiptGallery,
          ),
          (ReceiptSource.pdf, Icons.picture_as_pdf_outlined, l.expReceiptPdf),
        ])
          OutlinedButton.icon(
            key: ValueKey('receipt-${source.name}'),
            onPressed: enabled ? () => pick(source) : null,
            icon: Icon(icon),
            label: Text(label),
          ),
      ],
    );
  }
}

/// Thumbnail of a stored or pending receipt: the photo itself, or a PDF icon.
class ReceiptThumb extends StatelessWidget {
  const ReceiptThumb({super.key, required this.file, required this.kind});

  final File file;
  final ReceiptKind kind;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Widget icon(IconData data) => Icon(data, color: scheme.onSurfaceVariant);
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: kind == ReceiptKind.pdf
          ? icon(Icons.picture_as_pdf_outlined)
          : Image.file(
              file,
              width: 72,
              height: 72,
              fit: BoxFit.cover,
              cacheWidth: 144,
              errorBuilder: (_, _, _) =>
                  icon(Icons.image_not_supported_outlined),
            ),
    );
  }
}
