import 'package:flutter/material.dart';

class MovieCategoryTabs extends StatelessWidget {
  final List<String> labels;
  const MovieCategoryTabs({super.key, required this.labels});

  @override
  Widget build(BuildContext context) {
    final controller = DefaultTabController.of(context);
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Container(
          color: Theme.of(context).colorScheme.surface,
          height: kToolbarHeight,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                for (var i = 0; i < labels.length; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: GestureDetector(
                      onTap: () => controller.animateTo(i),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            labels[i],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: controller.index == i ? FontWeight.bold : FontWeight.normal,
                              color: controller.index == i ? Theme.of(context).colorScheme.primary : null,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 2,
                            width: 24,
                            color: controller.index == i ? Theme.of(context).colorScheme.primary : Colors.transparent,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
