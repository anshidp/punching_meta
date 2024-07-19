import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class DaysWidget extends ConsumerStatefulWidget {
  const DaysWidget({super.key});

  @override
  ConsumerState<DaysWidget> createState() => _DaysWidgetState();
}

final selectedDateProvider = StateProvider((ref) => "");

class _DaysWidgetState extends ConsumerState<DaysWidget> {
  int currentIndex = 0;
  final scrollController = ScrollController();
  final selectedDayProvider = StateProvider((ref) => "");

  List<Container> dateTimepackage() {
    try {
      List<Container> datedata = [];
      DateTime now = DateTime.now();
      final startingdate = DateTime(now.year, now.month, 1);
      final endDate = DateTime(now.year, startingdate.month + 1, 0);
      for (int i = 1; i <= endDate.day; i++) {
        final data = Container(
          margin: const EdgeInsets.all(5),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
          width: 50,
          height: 40,
          child: Consumer(builder: (context, ref, child) {
            bool isSelected = ref.read(selectedDayProvider) ==
                DateFormat("dd").format(DateTime(now.year, now.month, i));
            ref.watch(selectedDayProvider);
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    ref.read(selectedDayProvider.notifier).state =
                        DateFormat("dd")
                            .format(DateTime(now.year, now.month, i));
                    ref.read(selectedDateProvider.notifier).state =
                        DateFormat("dd-MM-yyyy")
                            .format(DateTime(now.year, now.month, i));
                  },
                  child: CircleAvatar(
                    backgroundColor: isSelected
                        ? const Color(0xff4FFFCA)
                        : Colors.transparent,
                    child: Text(
                      DateFormat("dd").format(DateTime(now.year, now.month, i)),
                      style: TextStyle(
                          color: isSelected ? Colors.black : Colors.white),
                    ),
                  ),
                ),
                Text(
                  DateFormat("EEE").format(DateTime(now.year, now.month, i)),
                  style: const TextStyle(color: Colors.white),
                )
              ],
            );
          }),
        );
        datedata.add(data);
        if (DateTime.now().day == i) {
          currentIndex = i - 1;
        }
      }
      return datedata;
    } catch (e) {
      throw Exception();
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Future.delayed(const Duration(milliseconds: 100)).then((value) => ref
              .read(selectedDayProvider.notifier)
              .state =
          DateFormat("dd").format(DateTime(
              DateTime.now().year, DateTime.now().month, DateTime.now().day)));

      scrollController.jumpTo(currentIndex * 60);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 500,
      height: 100,
      child: ListView.builder(
          controller: scrollController,
          itemCount: dateTimepackage().length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: dateTimepackage()[index],
              )),
    );
  }
}
