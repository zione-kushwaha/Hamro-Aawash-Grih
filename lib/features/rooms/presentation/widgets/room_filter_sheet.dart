import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../domain/entities/room_entity.dart';

class RoomFilterSheet extends StatefulWidget {
  final RoomType? selectedType;
  final double? maxPrice;
  final int? capacity;
  final void Function(RoomType?, double?, int?) onApply;

  const RoomFilterSheet({
    super.key,
    this.selectedType,
    this.maxPrice,
    this.capacity,
    required this.onApply,
  });

  @override
  State<RoomFilterSheet> createState() => _RoomFilterSheetState();
}

class _RoomFilterSheetState extends State<RoomFilterSheet> {
  RoomType? _type;
  double _maxPrice = 20000;
  int? _capacity;

  @override
  void initState() {
    super.initState();
    _type = widget.selectedType;
    _maxPrice = widget.maxPrice ?? 20000;
    _capacity = widget.capacity;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 40.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Filter Rooms', style: Theme.of(context).textTheme.titleLarge),
            TextButton(onPressed: () {
              setState(() { _type = null; _maxPrice = 20000; _capacity = null; });
            }, child: const Text('Reset')),
          ]),
          SizedBox(height: 16.h),
          Text('Room Type', style: Theme.of(context).textTheme.titleSmall),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            children: RoomType.values.map((t) => ChoiceChip(
              label: Text(t.name.toUpperCase()),
              selected: _type == t,
              onSelected: (s) => setState(() => _type = s ? t : null),
              selectedColor: AppColors.primaryLight,
            )).toList(),
          ),
          SizedBox(height: 16.h),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Max Price', style: Theme.of(context).textTheme.titleSmall),
            Text('Rs. ${_maxPrice.toStringAsFixed(0)}', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ]),
          Slider(
            value: _maxPrice,
            min: 1000,
            max: 50000,
            divisions: 49,
            onChanged: (v) => setState(() => _maxPrice = v),
            activeColor: AppColors.primary,
          ),
          SizedBox(height: 8.h),
          Text('Min Capacity', style: Theme.of(context).textTheme.titleSmall),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            children: [1, 2, 3, 4, 5].map((c) => ChoiceChip(
              label: Text('$c+'),
              selected: _capacity == c,
              onSelected: (s) => setState(() => _capacity = s ? c : null),
              selectedColor: AppColors.primaryLight,
            )).toList(),
          ),
          SizedBox(height: 24.h),
          AppButton(
            label: 'Apply Filters',
            onPressed: () {
              Navigator.pop(context);
              widget.onApply(_type, _maxPrice, _capacity);
            },
          ),
        ],
      ),
    );
  }
}
