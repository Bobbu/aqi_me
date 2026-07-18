import 'package:aqi_me/core/coord_parser.dart';
import 'package:aqi_me/data/aqi_service.dart';
import 'package:aqi_me/data/location_builders.dart';
import 'package:aqi_me/models/geocode_result.dart';
import 'package:aqi_me/models/location.dart';
import 'package:aqi_me/state/locations_controller.dart';
import 'package:aqi_me/state/providers.dart';
import 'package:aqi_me/ui/widgets/disambiguation_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The single smart input: accepts a place name *or* `lat, lon`, geocodes named
/// places (with disambiguation when needed), and enforces the 20-cap
/// (TECH_DESIGN §9.1).
class AddLocationField extends ConsumerStatefulWidget {
  const AddLocationField({super.key});

  @override
  ConsumerState<AddLocationField> createState() => _AddLocationFieldState();
}

class _AddLocationFieldState extends ConsumerState<AddLocationField> {
  final TextEditingController _controller = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final String text = _controller.text.trim();
    if (text.isEmpty || _busy) return;

    final LocationsController locations = ref.read(
      locationsControllerProvider.notifier,
    );
    if (locations.isFull) {
      _notify("You're tracking the maximum of 20 locations.");
      return;
    }

    final Coord? coord = tryParseCoordinates(text);
    if (coord != null) {
      _add(locationFromCoord(coord.lat, coord.lon));
      return;
    }

    setState(() => _busy = true);
    try {
      final List<GeocodeResult> matches = await ref
          .read(locationRepositoryProvider)
          .geocode(text);
      if (!mounted) return;

      if (matches.isEmpty) {
        _notify("Couldn't find a place matching “$text”.");
        return;
      }
      if (matches.length == 1) {
        _add(locationFromGeocode(matches.first));
        return;
      }
      final GeocodeResult? chosen = await showDisambiguationSheet(
        context,
        matches,
      );
      if (!mounted || chosen == null) return;
      _add(locationFromGeocode(chosen));
    } on AqiServiceException catch (e) {
      if (mounted) _notify(e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _add(Location location) {
    final AddOutcome outcome = ref
        .read(locationsControllerProvider.notifier)
        .add(location);
    switch (outcome) {
      case AddOutcome.added:
        _controller.clear();
      case AddOutcome.duplicate:
        _notify("You're already tracking ${location.label}.");
      case AddOutcome.full:
        _notify("You're tracking the maximum of 20 locations.");
    }
  }

  void _notify(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return TextField(
      controller: _controller,
      onSubmitted: (_) => _submit(),
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        hintText: 'Add a city, or  39.74, -104.99',
        filled: true,
        fillColor: theme.colorScheme.surface,
        prefixIcon: const Icon(Icons.add_location_alt_outlined),
        suffixIcon: Padding(
          padding: const EdgeInsets.all(6),
          child: _busy
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: Center(
                    child: SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              : FilledButton(onPressed: _submit, child: const Text('Add')),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: theme.colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: theme.colorScheme.outline),
        ),
      ),
    );
  }
}
